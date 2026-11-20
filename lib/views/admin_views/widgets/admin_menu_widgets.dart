// lib/views/admin_views/widgets/admin_menu_widgets.dart
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../../utils/app_constants/app_images_constant.dart';
import '../../../utils/app_constants/app_theme_constants.dart';
import '../../../utils/app_constants/colors_constant.dart';

/// خلفية الصفحة بنفس أسلوب شاشات المشرف (صورة الثيم الحالية).
class AdminPageBackground extends StatelessWidget {
  final Widget child;
  const AdminPageBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(AppImages.authBackground),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.linearToSrgbGamma(),
        ),
      ),
      child: child,
    );
  }
}

/// أنيميشن الظهور المتتابع المستخدم في شاشات المشرف.
class AdminAnimatedItem extends StatelessWidget {
  final int position;
  final Widget child;
  const AdminAnimatedItem({
    super.key,
    required this.position,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimationConfiguration.staggeredList(
      position: position,
      duration: const Duration(milliseconds: 500),
      child: SlideAnimation(
        verticalOffset: 50,
        child: FadeInAnimation(child: child),
      ),
    );
  }
}

/// عنوان قسم (دائرة متدرجة + نص) مثل صفحة الملف الشخصي.
class AdminSectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  const AdminSectionHeader({
    super.key,
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary400, AppColors.primary600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.white24, width: 1),
            ),
            child: Icon(icon, size: 18, color: AppColors.white),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryAccent,
              shadows: [
                Shadow(
                  color: AppColors.background.withValues(alpha: 0.6),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// بطاقة قائمة بحواف بيضوية (نفس شكل بطاقات المشرف).
class AdminMenuCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const AdminMenuCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppThemeConstants.borderRadius,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.cardColor.withValues(alpha: 0.95),
          borderRadius: AppThemeConstants.borderRadius,
          border: Border.all(color: color.withValues(alpha: 0.6), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.25),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 26, color: color),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// شبكة من عمودين لعرض بطاقات القائمة.
class AdminMenuGrid extends StatelessWidget {
  final List<Widget> children;
  const AdminMenuGrid({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      childAspectRatio: 1.25,
      children: children,
    );
  }
}
