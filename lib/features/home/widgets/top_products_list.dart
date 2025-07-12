import 'package:flutter/material.dart';

class TopProductsList extends StatelessWidget {
  final List<Map<String, dynamic>> products;
  const TopProductsList({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const SizedBox(
          height: 250,
          child: Center(child: Text('No product sales data available.'))
      );
    }

    return SizedBox(
      height: 250,
      child: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundImage: product['imageUrl'].isNotEmpty ? NetworkImage(product['imageUrl']) : null,
              child: product['imageUrl'].isEmpty ? const Icon(Icons.shopping_bag) : null,
            ),
            title: Text(product['name']),
            trailing: Text('Sold: ${product['count']}', style: const TextStyle(fontWeight: FontWeight.bold)),
          );
        },
      ),
    );
  }
}
