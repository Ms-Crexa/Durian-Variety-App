class Durian {
  final String id;
  final String name;
  final String fruitType;
  final String flavorProfile;
  final String description;
  final List<String> locations;
  final Map<String, String> images;

  Durian({
    required this.id,
    required this.name,
    required this.fruitType,
    required this.flavorProfile,
    required this.description,
    required this.locations,
    required this.images,
  });

  factory Durian.fromJson(Map<String, dynamic> json) {
    return Durian(
      id: json['id'],
      name: json['name'],
      fruitType: json['fruit_type'],
      flavorProfile: json['flavor_profile'],
      description: json['description'],
      locations: List<String>.from(json['locations']),
      images: Map<String, String>.from(json['images']),
    );
  }
}
