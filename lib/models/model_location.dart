class LocationModel {
  final int id;
  final String name;
  final double latitude;
  final double longitude;

  LocationModel(
    this.id,
    this.name,
    this.latitude,
    this.longitude,
  );

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      json['id'] as int? ?? 0,
      json['name'] as String? ?? "Unknown",
      (json['lat'] as num?)?.toDouble() ?? 0.0,
      (json['long'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
