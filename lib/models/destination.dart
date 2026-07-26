class Destination {
  final String name;
  final String location;
  final String image;
  final String description;
  final int price;
  final String category;
  final double rating;
  final int reviewsCount;
  final List<String> schedules;

  Destination({
    required this.name,
    required this.location,
    required this.image,
    required this.description,
    required this.price,
    required this.category,
    required this.rating,
    required this.reviewsCount,
    required this.schedules,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Destination &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;
}
