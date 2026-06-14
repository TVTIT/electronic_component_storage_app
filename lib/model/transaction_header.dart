import 'package:flutter/material.dart';

class TransactionHeader {
  final String id;
  final String? userId;
  final String userName;
  final TransactionType type;
  final String? notes;
  final int totalComponent;
  final int totalAmount;
  final DateTime createdAt;

  TransactionHeader({
    required this.id,
    this.userId,
    required this.userName,
    required this.type,
    this.notes,
    required this.totalComponent,
    required this.totalAmount,
    required this.createdAt,
  });

  factory TransactionHeader.fromMap(Map<String, dynamic> data) {
    return TransactionHeader(
      id: data['id'],
      userId: data['user_id'],
      userName: data['user_name'] ?? "Người dùng đã bị xoá",
      type: TransactionType.fromString(data['type']),
      notes: data['notes'],
      totalComponent: data['total_components'] ?? 0,
      totalAmount: data['total_amount'] ?? 0,
      createdAt: DateTime.tryParse(data['created_at']) ?? DateTime(2020),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'type': type.dbValue,
      'notes': notes,
      'total_components': totalComponent,
      'total_amount': totalAmount,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

enum TransactionType {
  import('IN'),
  export('OUT');

  final String dbValue;

  const TransactionType(this.dbValue);

  factory TransactionType.fromString(String value) {
    return TransactionType.values.firstWhere(
      (e) => e.dbValue == value,
      orElse: () =>
          throw ArgumentError('transaction type not available: $value'),
    );
  }

  String get displayName {
    switch (this) {
      case TransactionType.import:
        return 'Nhập kho';
      case TransactionType.export:
        return 'Xuất kho';
    }
  }

  Color get color {
    switch (this) {
      case TransactionType.import:
        return Colors.blue.shade200;
      case TransactionType.export:
        return Colors.orange.shade200;
    }
  }

  IconData get icon {
    switch (this) {
      case TransactionType.import:
        return Icons.move_to_inbox;
      case TransactionType.export:
        return Icons.outbox;
    }
  }
}
