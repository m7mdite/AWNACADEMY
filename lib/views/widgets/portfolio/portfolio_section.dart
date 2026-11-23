import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/public_controllers/portfolio_controller.dart';
import '../../../models/requests_models/portfolio_item_model.dart';
import '../../../services/functions/show_image_preview.dart';
import '../../../utils/app_constants/colors_constant.dart';
import '../../public_views/portfolio_screen.dart';

/// قسم "معرض الحالات" داخل الملف الشخصي.
/// [userId] = معرّف صاحب الملف، أو 'me' لملفي الشخصي.
class PortfolioSection extends StatefulWidget {
  final String userId;
  const PortfolioSection({super.key, required this.userId});

  @override
  State<PortfolioSection> createState() => _PortfolioSectionState();
}

class _PortfolioSectionState extends State<PortfolioSection> {
  static const int _previewCount = 6;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<PortfolioController>(tag: widget.userId)) {
      Get.put(PortfolioController(widget.userId), tag: widget.userId);
    }
  }

  @override
  void dispose() {
    // نحذف الكنترولر حتى يُجلب المعرض من جديد عند فتح الملف مرة ثانية
    Get.delete<PortfolioController>(tag: widget.userId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PortfolioController>(
      tag: widget.userId,
      builder: (c) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'معرض الحالات',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                if (c.isOwner && c.total > _previewCount)
                  TextButton(
                    onPressed: () =>
                        Get.to(() => PortfolioScreen(userId: widget.userId)),
                    child: Text('عرض الكل (${c.total})'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            _body(c),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }

  Widget _body(PortfolioController c) {
    if (!c.loaded) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    if (c.items.isEmpty) {
      final msg = c.failed
          ? 'تعذر تحميل المعرض'
          : c.isOwner
              ? 'لا توجد حالات مكتملة بعد. تظهر هنا الحالات التي لها صورة قبل وبعد المعالجة.'
              : 'لا توجد حالات معروضة';
      return Text(
        msg,
        style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
      );
    }

    final shown = c.items.take(_previewCount).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!c.isOwner)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'آخر ${c.items.length} حالات مكتملة',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
        SizedBox(
          height: 215,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: shown.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (_, i) => SizedBox(
              width: 250,
              child: PortfolioCard(item: shown[i]),
            ),
          ),
        ),
      ],
    );
  }
}

/// كرت حالة: صورة قبل + صورة بعد + نوع المعالجة والتاريخ.
class PortfolioCard extends StatelessWidget {
  final PortfolioItem item;
  final double imageHeight;

  const PortfolioCard({super.key, required this.item, this.imageHeight = 140});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => showPortfolioDetail(item),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: imageHeight,
              child: Row(
                children: [
                  Expanded(child: _PhotoHalf(url: item.beforeUrl, label: 'قبل')),
                  const SizedBox(width: 2),
                  Expanded(child: _PhotoHalf(url: item.afterUrl, label: 'بعد')),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item.caseType ?? 'حالة',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  if (item.rating != null) ...[
                    Icon(Icons.star_rounded, size: 16, color: AppColors.amber),
                    Text(
                      '${item.rating}/5  ',
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                  if (item.dateLabel.isNotEmpty)
                    Text(
                      item.dateLabel,
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoHalf extends StatelessWidget {
  final String? url;
  final String label;
  const _PhotoHalf({required this.url, required this.label});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _networkImage(url),
        Positioned(
          top: 6,
          right: 6,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.black.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              label,
              style: const TextStyle(color: AppColors.white, fontSize: 10),
            ),
          ),
        ),
      ],
    );
  }
}

Widget _networkImage(String? url, {BoxFit fit = BoxFit.cover}) {
  Widget fallback() => Container(
        color: AppColors.grey.withValues(alpha: 0.15),
        child: Icon(Icons.image_not_supported_outlined, color: AppColors.grey),
      );
  if (url == null || url.isEmpty) return fallback();
  return CachedNetworkImage(
    imageUrl: url,
    fit: fit,
    placeholder: (_, _) =>
        const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    errorWidget: (_, _, _) => fallback(),
  );
}

/// نافذة تفاصيل الحالة: الصورتان بحجم كبير، والضغط على الصورة يكبّرها.
void showPortfolioDetail(PortfolioItem item) {
  Widget photo(String title, String? url) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: url == null ? null : () => showImagePreview(url),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(aspectRatio: 4 / 3, child: _networkImage(url)),
          ),
        ),
      ],
    );
  }

  Get.dialog(
    Dialog(
      backgroundColor: AppColors.cardColor,
      insetPadding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              item.caseType ?? 'حالة',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            if (item.dateLabel.isNotEmpty)
              Text(
                item.dateLabel,
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            const SizedBox(height: 12),
            photo('قبل المعالجة', item.beforeUrl),
            const SizedBox(height: 12),
            photo('بعد المعالجة', item.afterUrl),
          ],
        ),
      ),
    ),
  );
}
