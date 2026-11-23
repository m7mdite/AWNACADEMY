import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/public_controllers/portfolio_controller.dart';
import '../../utils/app_constants/colors_constant.dart';
import '../widgets/portfolio/portfolio_section.dart';

/// صفحة "عرض الكل" لمعرض الحالات (لصاحب الملف). تستخدم نفس الكنترولر الذي أنشأه PortfolioSection.
class PortfolioScreen extends StatelessWidget {
  final String userId;
  const PortfolioScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<PortfolioController>(tag: userId);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('معرض الحالات'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: GetBuilder<PortfolioController>(
        tag: userId,
        builder: (_) {
          if (!c.loaded) {
            return const Center(child: CircularProgressIndicator());
          }
          if (c.items.isEmpty) {
            return Center(
              child: Text(
                'لا توجد حالات مكتملة بعد',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: c.refreshAll,
            child: NotificationListener<ScrollNotification>(
              onNotification: (n) {
                if (n.metrics.pixels >= n.metrics.maxScrollExtent - 200) {
                  c.loadMore();
                }
                return false;
              },
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: c.items.length + (c.hasMore ? 1 : 0),
                separatorBuilder: (_, _) => const SizedBox(height: 14),
                itemBuilder: (_, i) {
                  if (i >= c.items.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  }
                  return PortfolioCard(item: c.items[i], imageHeight: 180);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
