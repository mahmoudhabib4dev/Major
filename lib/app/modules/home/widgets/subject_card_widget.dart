import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/api_image.dart';
import '../controllers/home_controller.dart';
import '../../subjects/models/subject_model.dart';

class SubjectCardWidget extends GetView<HomeController> {
  final SubjectModel subject;

  const SubjectCardWidget({
    super.key,
    required this.subject,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => controller.onSubjectTap(subject),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 110,
        height: 110,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F6FA),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon from network or default asset
            subject.image != null
                ? ApiImage(
                    imageUrl: subject.image!,
                    width: 64,
                    height: 64,
                    fit: BoxFit.contain,
                    errorWidget: Image.asset(
                      'assets/icons/15.png',
                      width: 64,
                      height: 64,
                      fit: BoxFit.contain,
                    ),
                  )
                : Image.asset(
                    'assets/icons/15.png',
                    width: 64,
                    height: 64,
                    fit: BoxFit.contain,
                  ),
            const SizedBox(height: 8),
            // Subject title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                subject.name,
                style: AppTextStyles.subjectCardTitle(context),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
