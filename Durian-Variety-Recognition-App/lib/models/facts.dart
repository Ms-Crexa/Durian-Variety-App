class Fact {
  final String fact;

  Fact({
    required this.fact,
  });

  factory Fact.fromJson(Map<String, dynamic> json) {
    return Fact(
      fact: json['fact'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fact': fact,
    };
  }
}
