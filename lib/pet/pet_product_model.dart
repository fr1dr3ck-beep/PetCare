class PetModel {
  final int id;
  final String name;
  final String price;
  final String category;
  final String description;
  double averageRating;
  int ratingCount;

  PetModel({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.description,
    this.averageRating = 0.0,
    this.ratingCount = 0,
  });
}