import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherDayForecast {
  final DateTime dateTime;
  final double temp;
  final String icon;
  final int humidity;
  final double wind;
  final String description;
  final double rainProb;

  WeatherDayForecast({
    required this.dateTime,
    required this.temp,
    required this.icon,
    required this.humidity,
    required this.wind,
    required this.description,
    required this.rainProb,
  });
}

class WeatherService {
  final String apiKey = "0b924d8443bf94fde84a320a76d33248";

  Future<List<WeatherDayForecast>> getForecast(double lat, double lon) async {
    final url =
        "https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=metric&lang=pt_br";
    final resp = await http.get(Uri.parse(url));
    if (resp.statusCode == 200) {
      final data = json.decode(resp.body);
      List<WeatherDayForecast> forecast = [];
      for (var item in data['list']) {
        forecast.add(WeatherDayForecast(
          dateTime: DateTime.parse(item['dt_txt']),
          temp: (item['main']['temp'] as num).toDouble(),
          icon: item['weather'][0]['icon'],
          humidity: (item['main']['humidity'] as num).toInt(),
          wind: (item['wind']['speed'] as num).toDouble(),
          description: item['weather'][0]['description'],
          rainProb: (item['pop'] != null ? (item['pop'] as num) * 100.0 : 0.0),
        ));
      }
      return forecast;
    }
    throw Exception("Erro ao buscar previsão do tempo");
  }
   Future<double> getRainForecast(double lat, double lon) async {
    // TESTE DE SITUAÇÃO CRITICA- Verifica se a posição é aproximadamente Lapa (use tolerância pequena)
  if ((lat - (-23.5254)).abs() < 0.02 && (lon - (-46.6832)).abs() < 0.05) {
      print("Mock de precipitação ATIVADO para Lapa!");
      return 35.0; // valor alto para acionar alerta
  }
    final url =
        "https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=metric&lang=pt_br";
    final resp = await http.get(Uri.parse(url));
    if (resp.statusCode == 200) {
      final data = json.decode(resp.body);
      double rainTotal = 0.0;
      // Soma as próximas 8 previsões (24 horas, já que cada item é 3h)
      for (var i = 0; i < 8; i++) {
        final item = data['list'][i];
        if (item['rain'] != null && item['rain']['3h'] != null) {
          rainTotal += (item['rain']['3h'] as num).toDouble();
        }
      }
      return rainTotal;
    }
    throw Exception("Erro ao buscar precipitação prevista");
  }
}
