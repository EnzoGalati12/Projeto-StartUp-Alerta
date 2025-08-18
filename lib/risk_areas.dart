class RiskArea {
  final String name;
  final double latitude;
  final double longitude;
  final double radiusKm;

  RiskArea({required this.name, required this.latitude, required this.longitude, required this.radiusKm});
}

final List<RiskArea> riskAreas = [
  RiskArea(name: "Itaquera", latitude: -23.5454, longitude: -46.4608, radiusKm: 2),
  RiskArea(name: "Mooca", latitude: -23.5596, longitude: -46.6126, radiusKm: 2),
  RiskArea(name: "Lapa", latitude: -23.5254, longitude: -46.6832, radiusKm: 2.0),
  RiskArea(name: "Jabaquara", latitude: -23.6465, longitude: -46.6417, radiusKm: 2),
  RiskArea(name: "Brás", latitude: -23.5465, longitude: -46.6200, radiusKm: 2),
  // Adicione mais regiões conforme quiser
];
