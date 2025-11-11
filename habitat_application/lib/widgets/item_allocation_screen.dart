// widgets/item_allocation_screen.dart - FIXED COLOR PARSING

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/receipt_model.dart';

class ItemAllocationScreen extends StatefulWidget {
  final Receipt receipt;
  final Function(Receipt) onComplete;

  const ItemAllocationScreen({
    Key? key,
    required this.receipt,
    required this.onComplete,
  }) : super(key: key);

  @override
  State<ItemAllocationScreen> createState() => _ItemAllocationScreenState();
}

class _ItemAllocationScreenState extends State<ItemAllocationScreen> {
  late List<Person> _participants;
  late List<ReceiptItem> _items;
  late double _tax;
  late double _tip;
  bool _showAddParticipant = false;
  final TextEditingController _nameController = TextEditingController();

  // Color palette for participants - FIXED FORMAT (0xFF prefix)
  final List<Color> _colors = [
    const Color(0xFF6B8E6B), // Sage green
    const Color(0xFFFF6B6B), // Red
    const Color(0xFF4ECDC4), // Teal
    const Color(0xFFFFBE0B), // Yellow
    const Color(0xFF9B59B6), // Purple
    const Color(0xFF3498DB), // Blue
    const Color(0xFFE67E22), // Orange
    const Color(0xFF1ABC9C), // Turquoise
  ];

  @override
  void initState() {
    super.initState();
    _participants = List.from(widget.receipt.participants);
    _items = List.from(widget.receipt.data.items);
    _tax = widget.receipt.data.tax ?? 0;
    _tip = widget.receipt.data.tip ?? 0;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _addParticipant(String name) {
    if (name.trim().isEmpty) return;

    setState(() {
      final colorIndex = _participants.length % _colors.length;
      _participants.add(Person(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name.trim(),
        avatarColor: _colors[colorIndex].value.toRadixString(16).toUpperCase(),
      ));
      _nameController.clear();
      _showAddParticipant = false;
    });
  }

  void _removeParticipant(String personId) {
    setState(() {
      _participants.removeWhere((p) => p.id == personId);
      // Remove this person from all items
      for (var item in _items) {
        item.assignedTo.remove(personId);
      }
    });
  }

  void _toggleItemAssignment(ReceiptItem item, String personId) {
    setState(() {
      final index = _items.indexWhere((i) => i.id == item.id);
      if (item.assignedTo.contains(personId)) {
        _items[index] = item.copyWith(
          assignedTo: List.from(item.assignedTo)..remove(personId),
        );
      } else {
        _items[index] = item.copyWith(
          assignedTo: List.from(item.assignedTo)..add(personId),
        );
      }
    });
  }

  void _editItem(ReceiptItem item) {
    showDialog(
      context: context,
      builder: (context) => _EditItemDialog(
        item: item,
        onSave: (updatedItem) {
          setState(() {
            final index = _items.indexWhere((i) => i.id == item.id);
            _items[index] = updatedItem;
          });
        },
      ),
    );
  }

  void _updateTaxAndTip() {
    showDialog(
      context: context,
      builder: (context) => _TaxTipDialog(
        initialTax: _tax,
        initialTip: _tip,
        onSave: (tax, tip) {
          setState(() {
            _tax = tax;
            _tip = tip;
          });
        },
      ),
    );
  }

  void _complete() {
    if (_participants.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one person')),
      );
      return;
    }

    final hasUnassignedItems = _items.any((item) => item.assignedTo.isEmpty);
    if (hasUnassignedItems) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Unassigned Items'),
          content: const Text(
            'Some items haven\'t been assigned to anyone. Continue anyway?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _finishAllocation();
              },
              child: const Text('Continue'),
            ),
          ],
        ),
      );
    } else {
      _finishAllocation();
    }
  }

  void _finishAllocation() {
    final updatedData = ReceiptData(
      merchantName: widget.receipt.data.merchantName,
      merchantAddress: widget.receipt.data.merchantAddress,
      date: widget.receipt.data.date,
      items: _items,
      subtotal: widget.receipt.data.subtotal,
      tax: _tax,
      tip: _tip,
    );

    final updatedReceipt = Receipt(
      id: widget.receipt.id,
      imageUrl: widget.receipt.imageUrl,
      data: updatedData,
      participants: _participants,
      createdAt: widget.receipt.createdAt,
    );

    widget.onComplete(updatedReceipt);
  }

  Color _getPersonColor(Person person) {
  final raw = person.avatarColor;
  if (raw == null || raw.isEmpty) return _colors[0];

  var hex = raw.trim().toUpperCase();
  hex = hex.replaceFirst(RegExp(r'^0X'), '').replaceFirst('#', '');
  if (hex.length == 6) hex = 'FF$hex';
  if (hex.length != 8) return _colors[0];

  try {
    return Color(int.parse(hex, radix: 16));
  } catch (_) {
    return _colors[0];
  }
}

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Participants section
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Who\'s sharing?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Color(0xFF6B8E6B)),
                    onPressed: () => setState(() => _showAddParticipant = true),
                  ),
                ],
              ),
              if (_showAddParticipant)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            hintText: 'Enter name',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          onSubmitted: _addParticipant,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          setState(() {
                            _showAddParticipant = false;
                            _nameController.clear();
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.check),
                        onPressed: () => _addParticipant(_nameController.text),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _participants.map((person) {
                  return Chip(
                    avatar: CircleAvatar(
                      backgroundColor: _getPersonColor(person),
                      child: Text(
                        person.name[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    label: Text(person.name),
                    onDeleted: () => _removeParticipant(person.id),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // Items list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _items.length + 1, // +1 for tax/tip card
            itemBuilder: (context, index) {
              if (index == _items.length) {
                return _buildTaxTipCard();
              }

              final item = _items[index];
              return _buildItemCard(item);
            },
          ),
        ),

        // Bottom action bar
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: ElevatedButton(
              onPressed: _complete,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6B8E6B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                minimumSize: const Size(double.infinity, 0),
              ),
              child: const Text(
                'Continue to Summary',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItemCard(ReceiptItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${item.price.toStringAsFixed(2)} × ${item.quantity}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: () => _editItem(item),
                ),
                Text(
                  '\$${item.totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _participants.map((person) {
                final isAssigned = item.assignedTo.contains(person.id);
                final personColor = _getPersonColor(person);
                
                return FilterChip(
                  avatar: CircleAvatar(
                    backgroundColor: personColor,
                    radius: 12,
                    child: Text(
                      person.name[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  label: Text(person.name),
                  selected: isAssigned,
                  onSelected: (_) => _toggleItemAssignment(item, person.id),
                  selectedColor: personColor.withOpacity(0.3),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaxTipCard() {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: _updateTaxAndTip,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Tax', style: TextStyle(fontSize: 16)),
                  Text(
                    '\$${_tax.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Tip', style: TextStyle(fontSize: 16)),
                  Text(
                    '\$${_tip.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Edit Tax & Tip',
                    style: TextStyle(color: Color(0xFF6B8E6B)),
                  ),
                  Icon(Icons.edit, size: 18, color: Color(0xFF6B8E6B)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Dialog for editing item details
class _EditItemDialog extends StatefulWidget {
  final ReceiptItem item;
  final Function(ReceiptItem) onSave;

  const _EditItemDialog({required this.item, required this.onSave});

  @override
  State<_EditItemDialog> createState() => _EditItemDialogState();
}

class _EditItemDialogState extends State<_EditItemDialog> {
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _quantityController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item.name);
    _priceController = TextEditingController(
      text: widget.item.price.toStringAsFixed(2),
    );
    _quantityController = TextEditingController(
      text: widget.item.quantity.toString(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Item'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          TextField(
            controller: _priceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Price', prefixText: '\$'),
          ),
          TextField(
            controller: _quantityController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Quantity'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final updatedItem = widget.item.copyWith(
              name: _nameController.text,
              price: double.tryParse(_priceController.text) ?? widget.item.price,
              quantity: int.tryParse(_quantityController.text) ?? widget.item.quantity,
            );
            widget.onSave(updatedItem);
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

// Dialog for editing tax and tip
class _TaxTipDialog extends StatefulWidget {
  final double initialTax;
  final double initialTip;
  final Function(double, double) onSave;

  const _TaxTipDialog({
    required this.initialTax,
    required this.initialTip,
    required this.onSave,
  });

  @override
  State<_TaxTipDialog> createState() => _TaxTipDialogState();
}

class _TaxTipDialogState extends State<_TaxTipDialog> {
  late TextEditingController _taxController;
  late TextEditingController _tipController;

  @override
  void initState() {
    super.initState();
    _taxController = TextEditingController(
      text: widget.initialTax.toStringAsFixed(2),
    );
    _tipController = TextEditingController(
      text: widget.initialTip.toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _taxController.dispose();
    _tipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Tax & Tip'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _taxController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Tax', prefixText: '\$'),
          ),
          TextField(
            controller: _tipController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Tip', prefixText: '\$'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onSave(
              double.tryParse(_taxController.text) ?? widget.initialTax,
              double.tryParse(_tipController.text) ?? widget.initialTip,
            );
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}