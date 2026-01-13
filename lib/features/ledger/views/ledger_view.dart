import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../constants/app_styles.dart';
import '../../../utils/screen_utils.dart';
import '../../../utils/helpers.dart';
import '../controllers/ledger_controller.dart';
import '../models/ledger_entry_model.dart';

class LedgerView extends StatelessWidget {
  final LedgerController controller = Get.put(LedgerController());

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(ScreenUtils.setWidth(16)),
      child: Obx(
        () => AnimationLimiter(
          child: ListView.builder(
            itemCount: controller.ledgerEntries.length,
            itemBuilder: (context, index) {
              LedgerEntry entry = controller.ledgerEntries[index];
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  horizontalOffset: 50.0,
                  child: FadeInAnimation(
                    child: CustomCard(
                      child: ListTile(
                        title: Text(
                          entry.description,
                          style: AppStyles.bodyStyle,
                        ),
                        subtitle: Text(
                          'Debit: ${formatCurrency(entry.debit)} | Credit: ${formatCurrency(entry.credit)} | ${formatDate(entry.date)}',
                        ),
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
