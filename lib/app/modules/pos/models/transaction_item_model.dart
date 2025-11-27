class TransactionItemModel {
  final int? id;
  final int transactionId;
  final int productId;
  final String productName;
  final String sku;
  final int quantity;
  final double price;
  final double discount;
  final double subtotal;

  TransactionItemModel({
    this.id,
    required this.transactionId,
    required this.productId,
    required this.productName,
    required this.sku,
    required this.quantity,
    required this.price,
    this.discount = 0,
    required this.subtotal,
  });

  factory TransactionItemModel.fromMap(Map<String, dynamic> map) {
    return TransactionItemModel(
      id: map['id'],
      transactionId: map['transactionId'],
      productId: map['productId'],
      productName: map['productName'],
      sku: map['sku'],
      quantity: map['quantity'],
      price: (map['price'] as num).toDouble(),
      discount: (map['discount'] as num).toDouble(),
      subtotal: (map['subtotal'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'transactionId': transactionId,
      'productId': productId,
      'productName': productName,
      'sku': sku,
      'quantity': quantity,
      'price': price,
      'discount': discount,
      'subtotal': subtotal,
    };
  }
}
