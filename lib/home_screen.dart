import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'risk_areas.dart';
import 'weather_service.dart';
import 'chat_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Position? _position;
  bool _isInRisk = false;
  String _areaName = '';
  double _rainForecast = 0.0;
  bool _loading = true;
  String? _errorMsg;
  List<WeatherDayForecast> _weatherForecast = [];

  @override
  void initState() {
    super.initState();
    _getUserLocationAndAlert();
  }

  Future<void> _getUserLocationAndAlert() async {
    setState(() {
      _loading = true;
      _errorMsg = null;
    });
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _loading = false;
            _errorMsg =
                'Permissão de localização negada. Por favor, conceda a permissão para usar o app.';
          });
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _loading = false;
          _errorMsg =
              'Permissão de localização permanentemente negada. Ative manualmente nas configurações do dispositivo.';
        });
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );
      bool found = false;
      String area = '';
      for (var ra in riskAreas) {
        final distance = Geolocator.distanceBetween(
                pos.latitude, pos.longitude, ra.latitude, ra.longitude) /
            1000.0;
        if (distance <= ra.radiusKm) {
          found = true;
          area = ra.name;
          break;
        }
      }
      double rain =
          await WeatherService().getRainForecast(pos.latitude, pos.longitude);

      // Obtém a previsão detalhada
      List<WeatherDayForecast> weatherList =
          await WeatherService().getForecast(pos.latitude, pos.longitude);

      setState(() {
        _position = pos;
        _isInRisk = found;
        _areaName = area;
        _rainForecast = rain;
        _weatherForecast = weatherList;
        _loading = false;
        _errorMsg = null;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _errorMsg = 'Erro ao obter localização: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181C24),
      appBar: AppBar(
        backgroundColor: Colors.cyan[900],
        elevation: 0,
        title: Text(
          "Alerta Enchentes SP",
          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                  child: Card(
                    color: _isInRisk && _rainForecast > 10
                        ? Colors.red[600]
                        : (_isInRisk ? Colors.orange[700] : Colors.green[600]),
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18)),
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isInRisk
                                ? (_rainForecast > 10
                                    ? "⚠️ ALERTA DE ENCHENTE\nVocê está em área de risco ($_areaName) e há previsão de chuva forte!"
                                    : "Atenção: você está em área de risco ($_areaName), mas não há chuva forte prevista.")
                                : "Tudo certo! Você não está em área de risco de alagamento.",
                            style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Precipitação prevista: ${_rainForecast.toStringAsFixed(1)}mm",
                            style: GoogleFonts.montserrat(
                                color: const Color.fromARGB(179, 5, 5, 5),
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: Stack(
                    children: [
                      _position != null
                          ? FlutterMap(
                              options: MapOptions(
                                initialCenter: LatLng(
                                    _position!.latitude, _position!.longitude),
                                initialZoom: 15.0,
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate:
                                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                                  subdomains: const ['a', 'b', 'c'],
                                ),
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                      point: LatLng(_position!.latitude,
                                          _position!.longitude),
                                      width: 50,
                                      height: 50,
                                      child: const Icon(
                                        Icons.location_on,
                                        color: Colors.red,
                                        size: 44,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : const Center(
                              child: Text('Localização não disponível')),
                      // BOTÃO FLUTUANTE PARA ABRIR BOTTOM SHEET
                      Positioned(
                          bottom: 24,
                          right: 24,
                          child: Positioned(
                            bottom: 24,
                            right: 24,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                FloatingActionButton(
                                  heroTag: "chat_button",
                                  backgroundColor: Colors.cyan,
                                  tooltip: "Abrir Chat",
                                  elevation: 6,
                                  shape: const CircleBorder(),
                                  child: const Icon(Icons.chat,
                                      color: Colors.white),
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/chat');
                                  },
                                ),
                                const SizedBox(height: 12),
                                FloatingActionButton(
                                  backgroundColor: Colors.cyan[800],
                                  child: const Icon(Icons.wb_cloudy,
                                      color: Colors.white, size: 32),
                                  onPressed: () =>
                                      _showWeatherBottomSheet(context),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
                // BOTÃO DE ATUALIZAR LOCALIZAÇÃO
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyan[800],
                      foregroundColor: Colors.white,
                      minimumSize: const Size(220, 48),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24)),
                    ),
                    onPressed: _getUserLocationAndAlert,
                    icon: const Icon(Icons.refresh),
                    label: const Text("Atualizar localização"),
                  ),
                ),
                // RODAPÉ
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    "Dados de previsão: OpenWeatherMap | Áreas de risco: Defesa Civil/CGE-SP",
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
    );
  }

  // Bottom Sheet dinâmico com dados reais
  void _showWeatherBottomSheet(BuildContext context) {
    if (_weatherForecast.isEmpty) {
      showModalBottomSheet(
        context: context,
        builder: (_) => const Padding(
          padding: EdgeInsets.all(32.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
      return;
    }

    final now = _weatherForecast.first;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF222b39),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_getWeatherIcon(now.icon),
                  color: Colors.amber[400], size: 56),
              Text(
                "${now.temp.round()}°C   ${_capitalize(now.description)}",
                style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 28),
              ),
              Text(
                "Chuva: ${now.rainProb.round()}%  |  Umidade: ${now.humidity}%  |  Vento: ${now.wind} km/h",
                style:
                    GoogleFonts.montserrat(color: Colors.white70, fontSize: 15),
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Próximas horas:",
                  style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: 8, // mostra 24h de previsão (8 blocos de 3h)
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final forecast = _weatherForecast[i];
                    return _weatherHourCard(
                      "${forecast.dateTime.hour.toString().padLeft(2, '0')}:00",
                      "${forecast.temp.round()}°",
                      _getWeatherIcon(forecast.icon),
                    );
                  },
                ),
              ),
              const SizedBox(height: 18),
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _weatherHourCard(String hour, String temp, IconData icone) {
    return Card(
      color: const Color(0xFF283145),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone, color: Colors.amber[400], size: 26),
            const SizedBox(height: 2),
            Text(hour,
                style: const TextStyle(color: Colors.white, fontSize: 14)),
            Text(temp,
                style: const TextStyle(color: Colors.white, fontSize: 15)),
          ],
        ),
      ),
    );
  }

  IconData _getWeatherIcon(String code) {
    switch (code) {
      case '01d':
        return Icons.wb_sunny;
      case '01n':
        return Icons.nights_stay;
      case '02d':
      case '02n':
        return Icons.cloud;
      case '03d':
      case '03n':
        return Icons.cloud_queue;
      case '04d':
      case '04n':
        return Icons.cloud;
      case '09d':
      case '09n':
      case '10d':
      case '10n':
        return Icons.grain;
      case '11d':
      case '11n':
        return Icons.flash_on;
      case '13d':
      case '13n':
        return Icons.ac_unit;
      case '50d':
      case '50n':
        return Icons.blur_on;
      default:
        return Icons.cloud;
    }
  }

  String _capitalize(String s) => s[0].toUpperCase() + s.substring(1);
}
