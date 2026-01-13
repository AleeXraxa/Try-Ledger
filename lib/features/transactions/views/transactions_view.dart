import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../constants/app_styles.dart';
import '../../../utils/screen_utils.dart';
import '../../../utils/helpers.dart';
import '../controllers/transactions_controller.dart';
import '../models/transaction_model.dart';

class TransactionsView extends StatelessWidget {
  final TransactionsController controller = Get.put(TransactionsController());

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(ScreenUtils.setWidth(16)),
      child: Obx(
        () => AnimationLimiter(
          child: ListView.builder(
            itemCount: controller.transactions.length,
            itemBuilder: (context, index) {
              Transaction transaction = controller.transactions[index];
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: FadeInAnimation(
                  child: CustomCard(
                    child: ListTile(
                      title: Text(
                        transaction.type.isNotEmpty
                            ? '${transaction.type[0].toUpperCase()}${transaction.type.substring(1)}'
                            : '',
                        style: AppStyles.bodyStyle,
                      ),
                      subtitle: Text(
                        '${formatCurrency(transaction.amount)} | ${formatDate(transaction.date)}',
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class CustomCard extends StatelessWidget {
  final Widget child;

  const CustomCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      decoration: AppStyles.cardDecoration,
      child: child,
    );
  }
}
