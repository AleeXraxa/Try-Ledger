import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../constants/app_styles.dart';
import '../../../utils/screen_utils.dart';
import '../../../utils/helpers.dart';
import '../controllers/inventory_controller.dart';
import '../models/product_model.dart';

class InventoryView extends StatelessWidget {
  final InventoryController controller = Get.put(InventoryController());

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(ScreenUtils.setWidth(16)),
      child: Obx(
        () => AnimationLimiter(
          child: ListView.builder(
            itemCount: controller.products.length,
            itemBuilder: (context, index) {
              Product product = controller.products[index];
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  horizontalOffset: 50.0,
                  child: FadeInAnimation(
                    child: CustomCard(
                      child: ListTile(
                        title: Text(product.name, style: AppStyles.bodyStyle),
                        subtitle: Text(
                          'Stock: ${product.stock} | Price: ${formatCurrency(product.price)}',
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            // Edit product
                          },
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
