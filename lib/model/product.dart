class Products {
  String id;
  String name;
  String type;
  double price;
  String imageUrl;

  Products({
    required this.id,
    required this.name,
    required this.type,
    required this.price,
    required this.imageUrl,
  });

  // Phương thức tạo đối tượng Product từ Map lấy dữ liệu (Realtime Database)
  factory Products.fromMap(Map<dynamic, dynamic> map, String id) {
    return Products(
      id: id,
      name: map['name'] ?? '',
      type: map['type'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
    );
  }

  // Chuyển đối tượng Product thành Map để lưu vào Realtime Database
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'price': price,
      'imageUrl': imageUrl,
    };
  }
}
