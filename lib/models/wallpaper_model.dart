class Wallpaper {
  final String id;
  final String title;
  final String imagePath;
  final String category;
  final int views;

  Wallpaper({
    required this.id,
    required this.title,
    required this.imagePath,
    required this.category,
    required this.views,
  });

  factory Wallpaper.fromJson(Map<String, dynamic> json) {
    return Wallpaper(
      id: json['id'],
      title: json['title'],
      imagePath: json['image'],
      category: json['category'],
      views: json['views'],
    );
  }
}
