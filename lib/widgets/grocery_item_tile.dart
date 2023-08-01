import 'package:flutter/material.dart';

class ShopItemTile extends StatelessWidget {
  const ShopItemTile({
    super.key,
    required this.title,
    required this.color, required this.amount,

  });

  final String title;
  final Color color;
  final int amount;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 30,
        height: 30,
        color: color,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      trailing: Text(
        '$amount',
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
);
    // return Row(
    //   children: [
    //     Padding(
    //       padding: const EdgeInsets.all(16),
    //       child: Container(
    //         width: 30,
    //         height: 30,
    //         color: color,
    //       ),
    //     ),
    //     const SizedBox(width: 10),
    //     Text(
    //       title,
    //       style: const TextStyle(
    //         fontSize: 20,
    //         fontWeight: FontWeight.bold,
    //       ),
    //     ),
    //     const Spacer(),
    //     Text(
    //       '$amount',
    //       style: const TextStyle(
    //         fontSize: 20,
    //         fontWeight: FontWeight.bold,
    //       ),
    //     ),
    //     const SizedBox(width: 16),
    //   ],
    // );
  }
}
