import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../constants/app_styles.dart';
import '../../../utils/screen_utils.dart';

class BackupView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Backup', style: AppStyles.headingStyle),
        backgroundColor: AppStyles.primaryButtonStyle.backgroundColor?.resolve(
          {},
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(ScreenUtils.setWidth(16)),
        child: AnimationLimiter(
          child: Column(
            children: AnimationConfiguration.toStaggeredList(
              duration: const Duration(milliseconds: 375),
              childAnimationBuilder: (widget) => SlideAnimation(
                horizontalOffset: 50.0,
                child: FadeInAnimation(child: widget),
              ),
              children: [
                ElevatedButton(
                  onPressed: () {},
                  child: Text('Create Backup'),
                  style: AppStyles.primaryButtonStyle,
                ),
                SizedBox(height: ScreenUtils.setHeight(16)),
                ElevatedButton(
                  onPressed: () {},
                  child: Text('Restore Backup'),
                  style: AppStyles.primaryButtonStyle,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
