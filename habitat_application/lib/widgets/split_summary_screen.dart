// widgets/split_summary_screen.dart - FIXED COLOR PARSING

import 'package:flutter/material.dart';
import '../models/receipt_model.dart';

class SplitSummaryScreen extends StatelessWidget {
  final Receipt receipt;
  final VoidCallback onDone;

  const SplitSummaryScreen({
    Key? key,
    required this.receipt,
    required this.onDone,
  }) : super(key: key);

  // Helper function to safely parse color from string
  Color _getPersonColor(Person person) {
    if (person.avatarColor == null) return const Color(0xFF6B8E6B);
    try {
      // Remove any existing 0x or FF prefix and add proper format
      String colorStr = person.avatarColor!.toUpperCase();
      colorStr = colorStr.replaceAll('0X', '').replaceAll('FF', '');
      return Color(int.parse('0xFF$colorStr'));
    } catch (e) {
      return const Color(0xFF6B8E6B); // Fallback to sage green
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildReceiptInfoCard(),
              const SizedBox(height: 16),
              ..._buildPersonCards(),
              const SizedBox(height: 16),
              _buildTotalCard(),
            ],
          ),
        ),
        _buildBottomBar(context),
      ],
    );
  }

  Widget _buildReceiptInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (receipt.data.merchantName != null)
              Text(
                receipt.data.merchantName!,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            if (receipt.data.date != null)
              Text(
                _formatDate(receipt.data.date!),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Subtotal'),
                Text('\$${receipt.subtotal.toStringAsFixed(2)}'),
              ],
            ),
            if (receipt.tax > 0) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Tax'),
                  Text('\$${receipt.tax.toStringAsFixed(2)}'),
                ],
              ),
            ],
            if (receipt.tip > 0) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Tip'),
                  Text('\$${receipt.tip.toStringAsFixed(2)}'),
                ],
              ),
            ],
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '\$${receipt.grandTotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPersonCards() {
    return receipt.participants.map((person) {
      final total = person.calculateTotal(
        receipt.data.items,
        tax: receipt.tax,
        tip: receipt.tip,
      );
      final assignedItems = receipt.data.items
          .where((item) => item.assignedTo.contains(person.id))
          .toList();

      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Theme(
          data: ThemeData(dividerColor: Colors.transparent),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: _getPersonColor(person),
              child: Text(
                person.name[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              person.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: Text(
              '\$${total.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6B8E6B),
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (assignedItems.isEmpty)
                      const Text(
                        'No items assigned',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      )
                    else
                      ...assignedItems.map((item) {
                        final splitCount = item.assignedTo.length;
                        final itemCost = item.pricePerPerson();
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.name),
                                    if (splitCount > 1)
                                      Text(
                                        'Split $splitCount ways',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Text(
                                '\$${itemCost.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    if (assignedItems.isNotEmpty) ...[
                      const Divider(height: 16),
                      _buildBreakdownRow('Subtotal', _calculateSubtotal(person)),
                      if (receipt.tax > 0)
                        _buildBreakdownRow(
                          'Tax (proportional)',
                          _calculateProportionalTax(person),
                        ),
                      if (receipt.tip > 0)
                        _buildBreakdownRow(
                          'Tip (proportional)',
                          _calculateProportionalTip(person),
                        ),
                      const Divider(height: 16),
                      _buildBreakdownRow(
                        'Total',
                        total,
                        isBold: true,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget _buildBreakdownRow(String label, double amount, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  double _calculateSubtotal(Person person) {
    return receipt.data.items
        .where((item) => item.assignedTo.contains(person.id))
        .fold(0.0, (sum, item) => sum + item.pricePerPerson());
  }

  double _calculateProportionalTax(Person person) {
    final mySubtotal = _calculateSubtotal(person);
    final allSubtotal = receipt.data.items.fold(0.0, (sum, item) => sum + item.totalPrice);
    if (allSubtotal == 0) return 0;
    return receipt.tax * (mySubtotal / allSubtotal);
  }

  double _calculateProportionalTip(Person person) {
    final mySubtotal = _calculateSubtotal(person);
    final allSubtotal = receipt.data.items.fold(0.0, (sum, item) => sum + item.totalPrice);
    if (allSubtotal == 0) return 0;
    return receipt.tip * (mySubtotal / allSubtotal);
  }

  Widget _buildTotalCard() {
    final totalVerification = receipt.participants.fold(
      0.0,
      (sum, person) => sum +
          person.calculateTotal(
            receipt.data.items,
            tax: receipt.tax,
            tip: receipt.tip,
          ),
    );

    final isBalanced = (totalVerification - receipt.grandTotal).abs() < 0.01;

    return Card(
      color: isBalanced ? Colors.green[50] : Colors.orange[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              isBalanced ? Icons.check_circle : Icons.warning,
              color: isBalanced ? Colors.green : Colors.orange,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isBalanced
                    ? 'Everything adds up correctly!'
                    : 'Total doesn\'t match (difference: \$${(receipt.grandTotal - totalVerification).abs().toStringAsFixed(2)})',
                style: TextStyle(
                  color: isBalanced ? Colors.green[900] : Colors.orange[900],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Implement share functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Share functionality coming soon!')),
                      );
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: onDone,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6B8E6B),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Done'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}