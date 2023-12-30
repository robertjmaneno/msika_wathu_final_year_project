import 'package:flutter/material.dart';
import 'package:msika_wathu/views/buyer/custom_widhets/text_widget.dart';

class PriceWidget extends StatelessWidget {
  const PriceWidget({
    Key? key,
    required this.salePrice,
    required this.price,
    required this.textPrice,
    required this.isOnSale,
  }) : super(key: key);
  final double salePrice, price;
  final String textPrice;
  final bool isOnSale;
  @override
  Widget build(BuildContext context) {
    double userPrice = isOnSale ? salePrice : price;

    return FittedBox(
        child: Row(
      children: [
        TextWidget(
          text: '\$${(userPrice * int.parse(textPrice)).toStringAsFixed(2)}',
          color: Colors.green,
          textSize: 18,
        ),
        const SizedBox(
          width: 5,
        ),
        Visibility(
          visible: isOnSale ? true : false,
          child: Text(
            '\$${(price * int.parse(textPrice)).toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black,
              decoration: TextDecoration.lineThrough,
            ),
          ),
        ),
      ],
    ));
  }
}
