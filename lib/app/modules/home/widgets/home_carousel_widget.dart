import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_images.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/api_image.dart';
import '../../../core/widgets/app_loader.dart';
import '../controllers/home_controller.dart';

class HomeCarouselWidget extends GetView<HomeController> {
  const HomeCarouselWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return FadeInUp(
      duration: const Duration(milliseconds: 1000),
      delay: const Duration(milliseconds: 200),
      child: Obx(() {
        // Show loading indicator
        if (controller.isLoadingOffers.value) {
          return SizedBox(
            height: screenSize.height * 0.25,
            child: const Center(
              child: AppLoader(size: 50),
            ),
          );
        }

        // Show placeholder if no offers
        if (controller.offers.isEmpty) {
          return Container(
            height: screenSize.height * 0.25,
            width: screenSize.width * 0.8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              image: DecorationImage(
                image: AssetImage(AppImages.image4),
                fit: BoxFit.contain,
              ),
            ),
          );
        }

        // Show carousel with offers
        return Column(
          children: [
            CarouselSlider(
              options: CarouselOptions(
                height: screenSize.height * 0.25,
                enlargeCenterPage: true,
                autoPlay: true,
                aspectRatio: 16 / 9,
                autoPlayCurve: Curves.fastOutSlowIn,
                enableInfiniteScroll: controller.offers.length > 1,
                autoPlayAnimationDuration: const Duration(milliseconds: 800),
                viewportFraction: 0.8,
                onPageChanged: (index, reason) {
                  controller.updateCarouselIndex(index);
                },
              ),
              items: controller.offers.map((offer) {
                return Builder(
                  builder: (BuildContext context) {
                    return GestureDetector(
                      onTap: () => controller.onOfferTap(offer),
                      child: Container(
                        width: screenSize.width,
                        margin: const EdgeInsets.symmetric(horizontal: 0.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: AppColors.grey200,
                        ),
                        child: ClipRRectangle(
                          borderRadius: BorderRadius.circular(15),
                          child: ApiImage(
                            imageUrl: offer.image,
                            fit: BoxFit.cover,
                            placeholder: Container(
                              color: AppColors.grey200,
                              child: const Center(
                                child: AppLoader(size: 50),
                              ),
                            ),
                            errorWidget: Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(AppImages.image4),
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
            SizedBox(height: screenSize.height * 0.012),
            // Dots indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(controller.carouselItemCount, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: controller.currentCarouselIndex.value == index
                        ? AppColors.indicatorActive
                        : AppColors.indicatorInactive.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
          ],
        );
      }),
    );
  }
}

class ClipRRectangle extends StatelessWidget {
  final Widget child;
  final BorderRadius borderRadius;

  const ClipRRectangle({
    super.key,
    required this.child,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: child,
    );
  }
}
