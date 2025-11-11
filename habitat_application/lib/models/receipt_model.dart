// models/receipt_model.dart

class Receipt {
  final String id;
  final String? imageUrl;
  final DateTime createdAt;
  final ReceiptData data;
  final List<Person> participants;

  Receipt({
    required this.id,
    this.imageUrl,
    required this.data,
    required this.participants,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  double get total => data.items.fold(0, (sum, item) => sum + item.totalPrice);
  double get subtotal => data.subtotal ?? total;
  double get tax => data.tax ?? 0;
  double get tip => data.tip ?? 0;
  double get grandTotal => subtotal + tax + tip;

  Map<String, dynamic> toJson() => {
        'id': id,
        'imageUrl': imageUrl,
        'createdAt': createdAt.toIso8601String(),
        'data': data.toJson(),
        'participants': participants.map((p) => p.toJson()).toList(),
      };

  factory Receipt.fromJson(Map<String, dynamic> json) => Receipt(
        id: json['id'],
        imageUrl: json['imageUrl'],
        createdAt: DateTime.parse(json['createdAt']),
        data: ReceiptData.fromJson(json['data']),
        participants: (json['participants'] as List)
            .map((p) => Person.fromJson(p))
            .toList(),
      );
}

class ReceiptData {
  final String? merchantName;
  final String? merchantAddress;
  final DateTime? date;
  final List<ReceiptItem> items;
  final double? subtotal;
  final double? tax;
  final double? tip;

  ReceiptData({
    this.merchantName,
    this.merchantAddress,
    this.date,
    required this.items,
    this.subtotal,
    this.tax,
    this.tip,
  });

  Map<String, dynamic> toJson() => {
        'merchantName': merchantName,
        'merchantAddress': merchantAddress,
        'date': date?.toIso8601String(),
        'items': items.map((i) => i.toJson()).toList(),
        'subtotal': subtotal,
        'tax': tax,
        'tip': tip,
      };

  factory ReceiptData.fromJson(Map<String, dynamic> json) => ReceiptData(
        merchantName: json['merchantName'],
        merchantAddress: json['merchantAddress'],
        date: json['date'] != null ? DateTime.parse(json['date']) : null,
        items: (json['items'] as List)
            .map((i) => ReceiptItem.fromJson(i))
            .toList(),
        subtotal: json['subtotal'],
        tax: json['tax'],
        tip: json['tip'],
      );
}

class ReceiptItem {
  final String id;
  final String name;
  final double price;
  final int quantity;
  final List<String> assignedTo; // Person IDs

  ReceiptItem({
    required this.id,
    required this.name,
    required this.price,
    this.quantity = 1,
    List<String>? assignedTo,
  }) : assignedTo = assignedTo ?? [];

  double get totalPrice => price * quantity;

  // Calculate how much each person owes for this item
  double pricePerPerson() {
    if (assignedTo.isEmpty) return 0;
    return totalPrice / assignedTo.length;
  }

  ReceiptItem copyWith({
    String? id,
    String? name,
    double? price,
    int? quantity,
    List<String>? assignedTo,
  }) {
    return ReceiptItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      assignedTo: assignedTo ?? this.assignedTo,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'quantity': quantity,
        'assignedTo': assignedTo,
      };

  factory ReceiptItem.fromJson(Map<String, dynamic> json) => ReceiptItem(
        id: json['id'],
        name: json['name'],
        price: json['price'],
        quantity: json['quantity'] ?? 1,
        assignedTo: List<String>.from(json['assignedTo'] ?? []),
      );
}

class Person {
  final String id;
  final String name;
  final String? avatarColor; // For visual identification

  Person({
    required this.id,
    required this.name,
    this.avatarColor,
  });

  // Calculate total amount owed by this person
  double calculateTotal(List<ReceiptItem> items, {double? tax, double? tip}) {
    double itemsTotal = 0;
    double myItemsSubtotal = 0;
    double allItemsSubtotal = 0;

    for (var item in items) {
      allItemsSubtotal += item.totalPrice;
      if (item.assignedTo.contains(id)) {
        myItemsSubtotal += item.pricePerPerson();
        itemsTotal += item.pricePerPerson();
      }
    }

    // Proportionally split tax and tip based on items
    if (allItemsSubtotal > 0) {
      final proportion = myItemsSubtotal / allItemsSubtotal;
      if (tax != null) itemsTotal += tax * proportion;
      if (tip != null) itemsTotal += tip * proportion;
    }

    return itemsTotal;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'avatarColor': avatarColor,
      };

  factory Person.fromJson(Map<String, dynamic> json) => Person(
        id: json['id'],
        name: json['name'],
        avatarColor: json['avatarColor'],
      );
}