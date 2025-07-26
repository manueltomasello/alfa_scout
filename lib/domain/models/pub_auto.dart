class Pub {
  final String id;
  final String title;
  final String model;
  final String description;
  final double price;
  final int km;
  final List<String> imagePaths;
  final String ownerId;

  Pub({
    required this.id,
    required this.title,
    required this.model,
    required this.description,
    required this.price,
    required this.km,
    required this.imagePaths,
    required this.ownerId,
  });

  factory Pub.fromJson(Map<String, dynamic> json) {
    return Pub(
      id: json['id'] as String,
      title: json['title'] as String,
      model: json['model'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      km: json['km'] as int,
      imagePaths: List<String>.from(json['imagePaths']),
      ownerId: json['ownerId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'model': model,
      'description': description,
      'price': price,
      'km': km,
      'imagePaths': imagePaths,
      'ownerId': ownerId,
    };
  }

  Pub copyWith({
    String? id,
    String? title,
    String? model,
    String? description,
    double? price,
    int? km,
    List<String>? imagePaths,
    String? ownerId,
  }) {
    return Pub(
      id: id ?? this.id,
      title: title ?? this.title,
      model: model ?? this.model,
      description: description ?? this.description,
      price: price ?? this.price,
      km: km ?? this.km,
      imagePaths: imagePaths ?? this.imagePaths,
      ownerId: ownerId ?? this.ownerId,
    );
  }
}
