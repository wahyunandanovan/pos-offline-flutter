class ProductModel {
  final int? id;
  final String sku;
  final String name;
  final String? description;
  final String? category;
  final double buyPrice;
  final double sellPrice;
  final int stock;
  final int minStock;
  final int soldQuantity;
  final String? barcode;
  final String? imagePath;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductModel({
    this.id,
    required this.sku,
    required this.name,
    this.description,
    this.category,
    required this.buyPrice,
    required this.sellPrice,
    required this.stock,
    this.minStock = 0,
    this.soldQuantity = 0,
    this.barcode,
    this.imagePath,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'],
      sku: map['sku'],
      name: map['name'],
      description: map['description'],
      category: map['category'],
      buyPrice: (map['buyPrice'] as num).toDouble(),
      sellPrice: (map['sellPrice'] as num).toDouble(),
      stock: map['stock'],
      minStock: map['minStock'] ?? 0,
      soldQuantity: map['soldQuantity'] ?? 0,
      barcode: map['barcode'],
      imagePath: map['imagePath'],
      isActive: map['isActive'] == 1,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sku': sku,
      'name': name,
      'description': description,
      'category': category,
      'buyPrice': buyPrice,
      'sellPrice': sellPrice,
      'stock': stock,
      'minStock': minStock,
      'soldQuantity': soldQuantity,
      'barcode': barcode,
      'imagePath': imagePath,
      'isActive': isActive ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  ProductModel copyWith({
    int? id,
    String? sku,
    String? name,
    String? description,
    String? category,
    double? buyPrice,
    double? sellPrice,
    int? stock,
    int? minStock,
    int? soldQuantity,
    String? barcode,
    String? imagePath,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      sku: sku ?? this.sku,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      buyPrice: buyPrice ?? this.buyPrice,
      sellPrice: sellPrice ?? this.sellPrice,
      stock: stock ?? this.stock,
      minStock: minStock ?? this.minStock,
      soldQuantity: soldQuantity ?? this.soldQuantity,
      barcode: barcode ?? this.barcode,
      imagePath: imagePath ?? this.imagePath,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  double get profit => sellPrice - buyPrice;
  double get profitMargin => (profit / buyPrice) * 100;
  bool get isLowStock => stock <= minStock;
  bool get isPopular => soldQuantity > 10;
}
