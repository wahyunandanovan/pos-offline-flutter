// lib/app/modules/pos/models/transaction_model.dart
class TransactionModel {
  final int? id;
  final String transactionCode;
  final int userId;
  final String userName;
  final double subtotal;
  final double discount;
  final double tax;
  final double total;
  final double paid;
  final double change;
  final String paymentMethod;
  final String? notes;
  final String status;
  final DateTime createdAt;

  TransactionModel({
    this.id,
    required this.transactionCode,
    required this.userId,
    required this.userName,
    required this.subtotal,
    this.discount = 0,
    this.tax = 0,
    required this.total,
    required this.paid,
    this.change = 0,
    required this.paymentMethod,
    this.notes,
    this.status = 'completed',
    required this.createdAt,
  });

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      transactionCode: map['transactionCode'],
      userId: map['userId'],
      userName: map['userName'],
      subtotal: (map['subtotal'] as num).toDouble(),
      discount: (map['discount'] as num).toDouble(),
      tax: (map['tax'] as num).toDouble(),
      total: (map['total'] as num).toDouble(),
      paid: (map['paid'] as num).toDouble(),
      change: (map['change'] as num).toDouble(),
      paymentMethod: map['paymentMethod'],
      notes: map['notes'],
      status: map['status'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'transactionCode': transactionCode,
      'userId': userId,
      'userName': userName,
      'subtotal': subtotal,
      'discount': discount,
      'tax': tax,
      'total': total,
      'paid': paid,
      'change': change,
      'paymentMethod': paymentMethod,
      'notes': notes,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
