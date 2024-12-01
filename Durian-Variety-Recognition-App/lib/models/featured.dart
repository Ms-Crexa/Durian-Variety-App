class FeaturedVariety {
  final String name;
  final String image;
  final String description;

  FeaturedVariety({
    required this.name,
    required this.image,
    required this.description,
  });

  factory FeaturedVariety.fromJson(Map<String, dynamic> json) {
    return FeaturedVariety(
      name: json['name'],
      image: json['image'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'image': image,
      'description': description,
    };
  }
}
