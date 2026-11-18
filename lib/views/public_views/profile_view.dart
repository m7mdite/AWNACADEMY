import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../controllers/conversations_controllers/conversations_controller.dart';
import '../../controllers/public_controllers/public_controller.dart';
import '../../models/public_models/profile_model.dart';
import '../../services/functions/show_image_preview.dart';
import '../../utils/app_constants/app_images_constant.dart';
import '../../utils/app_constants/app_theme_constants.dart';
import '../../utils/app_constants/colors_constant.dart';
import '../../utils/app_constants/status_request.dart';
import '../widgets/dialog/report_user_dialog.dart';

enum ProfileViewMode { page, dialog }
/// ============================================================
class ProfileView extends StatelessWidget {
  final String? userId;
  final ProfileModel? profile;
  final ProfileViewMode mode;

  const ProfileView({
    super.key,
    this.userId,
    this.profile,
    this.mode = ProfileViewMode.page,
  }) : assert(userId != null || profile != null,
            'لازم تمرر إما userId أو profile');

  @override
  Widget build(BuildContext context) {
    final PublicController controller = Get.find<PublicController>();

    final bool needsFetch = profile == null &&
        (controller.otherProfile == null ||
            controller.otherProfile!.user != userId);

    if (needsFetch && userId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.getOtherProfile(userId!);
      });
    }

    return GetBuilder<PublicController>(
      builder: (ctrl) {
        final ProfileModel? resolved = profile ?? ctrl.otherProfile;
        final status = ctrl.statusRequest;

        if (resolved == null && status == StatusRequest.loading) {
          return _LoadingState(mode: mode);
        }

        if (resolved == null) {
          return _ErrorState(mode: mode);
        }

        return mode == ProfileViewMode.page
            ? _ProfilePageBody(
                profile: resolved,
                onRefresh: () async {
                  if (userId != null) {
                    await controller.getOtherProfile(userId!);
                  }
                },
              )
            : _ProfileDialogBody(profile: resolved);
      },
    );
  }
}

/// ============================================================
/// دالة مساعدة لفتح البروفايل كديالوغ من أي مكان بالتطبيق
/// (تحل محل: Get.dialog(Container(... ViewOtherProfile ...)))
///
/// ✅ تحافظ على نفس شكل الديالوغ القديم (الإطار، الحواف، الخلفية)
/// ✅ لكن بدون أي مشاكل طفح (Overflow) لأنها:
///    - تحدد ارتفاع/عرض أقصى عبر ConstrainedBox
///    - تسمح بالسكرول الداخلي فقط عند الحاجة
///    - المحتوى يتقلّص (shrink-wrap) لحجمه الفعلي بدل أخذ كل الشاشة
/// ============================================================
Future<void> showProfileDialog(
  BuildContext context, {
  String? userId,
  ProfileModel? profile,
}) {
  return Get.dialog(
    Dialog(
      backgroundColor: AppColors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: Get.width * 0.08,
        vertical: Get.height * 0.08,
      ),
      child: ConstrainedBox(
        // ✅ حد أقصى للارتفاع والعرض => ما في احتمال Overflow إطلاقًا
        constraints: BoxConstraints(
          maxHeight: Get.height * 0.85,
          maxWidth: Get.width * 0.92,
        ),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.elliptical(1, 10),
              topRight: Radius.elliptical(10, 1),
              bottomLeft: Radius.elliptical(10, 1),
              bottomRight: Radius.elliptical(1, 10),
            ),
            border: Border.all(color: AppColors.borderColor, width: 1.5),
          ),
          child: ProfileView(
            userId: userId,
            profile: profile,
            mode: ProfileViewMode.dialog,
          ),
        ),
      ),
    ),
  );
}

/// ================= حالة التحميل =================
class _LoadingState extends StatelessWidget {
  final ProfileViewMode mode;
  const _LoadingState({required this.mode});

  @override
  Widget build(BuildContext context) {
    final indicator = Center(
      child: CircularProgressIndicator(color: AppColors.primary),
    );
    if (mode == ProfileViewMode.dialog) {
      return SizedBox(height: 220, child: indicator);
    }
    return Scaffold(
      backgroundColor: AppColors.background,
      body: indicator,
    );
  }
}

/// ================= حالة الخطأ =================
class _ErrorState extends StatelessWidget {
  final ProfileViewMode mode;
  const _ErrorState({required this.mode});

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.error_outline, size: 48, color: AppColors.grey400),
        const SizedBox(height: 12),
        Text(
          'حدث خطأ أثناء تحميل الملف الشخصي',
          style: TextStyle(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );

    if (mode == ProfileViewMode.dialog) {
      return SizedBox(
        height: 220,
        child: Center(child: content),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(backgroundColor: AppColors.surface),
      body: Center(child: content),
    );
  }
}

/// ================================================================
/// جسم "صفحة" البروفايل الكاملة (بديل PublicProfileScreen)
/// ================================================================
class _ProfilePageBody extends StatelessWidget {
  final ProfileModel profile;
  final Future<void> Function() onRefresh;

  const _ProfilePageBody({required this.profile, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final ConversationsController convController =
        Get.find<ConversationsController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: onRefresh,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                backgroundColor: AppColors.background,
                foregroundColor: AppColors.textPrimary,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
                  onPressed: () => Get.back(),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    color: AppColors.surface,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Spacer(flex: 2),
                        Hero(
                          tag: 'profile_${profile.user}',
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                    color: AppColors.black12,
                                    blurRadius: 12,
                                    offset: const Offset(0, 4)),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 70,
                              backgroundColor: AppColors.grey200,
                              backgroundImage: (profile.profilePhoto?.url != null &&
                                      profile.profilePhoto!.url!.isNotEmpty)
                                  ? NetworkImage("${profile.profilePhoto!.url}")
                                  : AssetImage(AppImages.authBackground)
                                      as ImageProvider,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '${profile.firstName} ${profile.fatherName} ${profile.lastName}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary50,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _roleTitle(profile.role ?? ""),
                            style: TextStyle(
                                color: AppColors.primary700, fontSize: 14),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => convController
                                    .openConversation(profile.user ?? ""),
                                icon: const Icon(Icons.chat_bubble_outline,
                                    size: 18),
                                label: const Text('مراسلة'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: AppColors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30)),
                                  elevation: 0,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => Get.dialog(ReportUserDialog(
                                    reportedUserId: profile.user!)),
                                icon: const Icon(Icons.flag_outlined, size: 18),
                                label: const Text('إبلاغ'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.error,
                                  side: const BorderSide(color: AppColors.error),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        if (profile.phoneNumber != null &&
                            profile.phoneNumber!.isNotEmpty) ...[
                          _sectionTitle('معلومات الاتصال'),
                          const SizedBox(height: 8),
                          _infoCard([
                            _infoTile(Icons.phone_outlined, profile.phoneNumber!,
                                () => _copyToClipboard(profile.phoneNumber!)),
                          ]),
                          const SizedBox(height: 24),
                        ],
                        if (profile.role == 'student') ...[
                          _sectionTitle('معلومات أكاديمية'),
                          const SizedBox(height: 8),
                          _infoCard([
                            if (profile.universityNumber != null &&
                                profile.universityNumber!.isNotEmpty)
                              _infoTile(
                                  Icons.badge_outlined,
                                  'الرقم الجامعي: ${profile.universityNumber}',
                                  () => _copyToClipboard(
                                      profile.universityNumber!)),
                            if (profile.category?.category != null) ...[
                              _infoTile(Icons.calendar_today_outlined,
                                  'السنة: ${_extractYear(profile.category!.category!)}'),
                              _infoTile(Icons.group_outlined,
                                  'الفئة: ${_extractSpecialty(profile.category!.category!)}'),
                            ],
                          ]),
                          const SizedBox(height: 24),
                        ],
                        if (profile.role == 'patient') ...[
                          _sectionTitle('معلومات صحية'),
                          const SizedBox(height: 8),
                          _infoCard([
                            if (profile.phoneNumber != null)
                              _infoTile(Icons.cake_outlined,
                                  'رقم الجوال: ${profile.phoneNumber} '),
                            if (profile.gender != null &&
                                profile.gender!.isNotEmpty)
                              _infoTile(Icons.people_outline,
                                  'الجنس: ${profile.gender == 'male' ? 'ذكر' : 'أنثى'}'),
                          ]),
                          const SizedBox(height: 24),
                        ],
                        if (profile.bio != null && profile.bio!.isNotEmpty) ...[
                          _sectionTitle('نبذة'),
                          const SizedBox(height: 8),
                          Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            color: AppColors.cardColor,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                profile.bio!,
                                style: TextStyle(
                                  fontSize: 15,
                                  height: 1.4,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ],
                    ),
                  ),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


/// ================================================================
class _ProfileDialogBody extends StatelessWidget {
  final ProfileModel profile;
  const _ProfileDialogBody({required this.profile});

  @override
  Widget build(BuildContext context) {
    final ConversationsController convController =
        Get.find<ConversationsController>();

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 5),
          Center(
            child: InkWell(
              onTap: () {
                final url = profile.profilePhoto?.url;
                if (url != null && url.isNotEmpty) {
                  showImagePreview(url);
                }
              },
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                padding: const EdgeInsets.all(5),
                height: 130,
                width: 130,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary,
                      blurRadius: 20,
                      spreadRadius: 1,
                    )
                  ],
                  borderRadius: BorderRadius.circular(100),
                  image: DecorationImage(
                    image: AssetImage(AppImages.authBackground),
                    fit: BoxFit.cover,
                  ),
                  border: Border.all(
                    color: AppColors.primary,
                    strokeAlign: 5,
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: AppColors.grey200,
                  backgroundImage: (profile.profilePhoto?.url != null &&
                          profile.profilePhoto!.url!.isNotEmpty)
                      ? NetworkImage("${profile.profilePhoto!.url}")
                      : AssetImage(AppImages.authBackground) as ImageProvider,
                ),
              ),
            ),
          ),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    '${profile.firstName} ${profile.lastName}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 3),
                Icon(Icons.verified, color: AppColors.primary, size: 18),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              ElevatedButton.icon(
                onPressed: () =>
                    convController.openConversation(profile.user ?? ""),
                label: const Text("مراسلة"),
                icon: const Icon(Icons.message, size: 18),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  iconColor: AppColors.white,
                  foregroundColor: AppColors.white,
                  elevation: 5,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  side: BorderSide(
                      color: AppColors.primary, width: 2, strokeAlign: 3),
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppThemeConstants.borderRadius,
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Get.dialog(
                    ReportUserDialog(reportedUserId: profile.user ?? ""),
                    barrierDismissible: false,
                  );
                },
                label: const Text("إبلاغ"),
                icon: const Icon(Icons.report, size: 18),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  iconColor: AppColors.white,
                  foregroundColor: AppColors.white,
                  elevation: 5,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  side: BorderSide(
                      color: AppColors.error, width: 2, strokeAlign: 3),
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppThemeConstants.borderRadius,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _divider(),
          const SizedBox(height: 10),
          if (profile.role == "student" && profile.category?.category != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: _infoItem(
                      icon: Icons.school,
                      label: "السنة: ",
                      value: _extractYear(profile.category!.category!),
                    ),
                  ),
                  _verticalDivider(),
                  Flexible(
                    child: _infoItem(
                      icon: Icons.group,
                      label: "الفئة: ",
                      value: _extractSpecialty(profile.category!.category!),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            _divider(),
            const SizedBox(height: 10),
          ],
          if (profile.role == "patient") ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: _infoItem(
                      icon: Icons.phone_outlined,
                      label: "الهاتف: ",
                      value: profile.phoneNumber ?? 'غير محدد',
                    ),
                  ),
                  _verticalDivider(),
                  Flexible(
                    child: _infoItem(
                      icon: Icons.people_outline,
                      label: "الجنس: ",
                      value: profile.gender == 'male'
                          ? 'ذكر'
                          : (profile.gender == 'female' ? 'أنثى' : 'غير محدد'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
          if (profile.bio != null && profile.bio!.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.cardColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.elliptical(1, 10),
                  topRight: Radius.elliptical(10, 1),
                  bottomLeft: Radius.elliptical(10, 1),
                  bottomRight: Radius.elliptical(1, 10),
                ),
                border: Border.all(
                  color: AppColors.primary,
                  width: 1,
                  strokeAlign: 3,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "نبذة عن العضو",
                    style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profile.bio!,
                    style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

/// ================= عناصر مساعدة مشتركة (نفس السلوك بالنسختين) =================

Widget _sectionTitle(String title) {
  return Text(
    title,
    style: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
  );
}

Widget _infoCard(List<Widget> children) {
  return Card(
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    color: AppColors.cardColor,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(children: children),
    ),
  );
}

Widget _infoTile(IconData icon, String text, [VoidCallback? onTap]) {
  return ListTile(
    leading: Icon(icon, color: AppColors.primary700, size: 24),
    title: Text(text, style: TextStyle(fontSize: 16, color: AppColors.textPrimary)),
    trailing:
        onTap != null ? Icon(Icons.copy, size: 18, color: AppColors.textSecondary) : null,
    onTap: onTap,
    contentPadding: EdgeInsets.zero,
  );
}

Widget _divider() {
  return Container(
    height: 1,
    margin: const EdgeInsets.symmetric(horizontal: 50),
    decoration: BoxDecoration(
      color: AppColors.borderColor,
      boxShadow: [
        BoxShadow(
          color: AppColors.primary.withValues(alpha: 0.3),
          blurRadius: 10,
          spreadRadius: 2,
        ),
      ],
    ),
  );
}

Widget _verticalDivider() {
  return Container(
    width: 1,
    height: 15,
    margin: const EdgeInsets.symmetric(horizontal: 10),
    decoration: BoxDecoration(
      color: AppColors.borderColor,
      boxShadow: [
        BoxShadow(
          color: AppColors.primary.withValues(alpha: 0.3),
          blurRadius: 10,
          spreadRadius: 2,
        ),
      ],
    ),
  );
}

Widget _infoItem({
  required IconData icon,
  required String label,
  required String value,
}) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, color: AppColors.primaryAccent, size: 16),
      const SizedBox(width: 2),
      Text(
        label,
        style: TextStyle(
          fontSize: 14,
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(width: 3),
      Flexible(
        child: Text(
          value,
          style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );
}

String _roleTitle(String role) {
  switch (role) {
    case 'student':
      return 'طالب';
    case 'patient':
      return 'مريض';
    case 'overseer':
      return 'مشرف';
    default:
      return role;
  }
}

String _extractYear(String categoryString) {
  final match = RegExp(r'^\d+').firstMatch(categoryString);
  if (match != null) return 'السنة ${match.group(0)}';
  return 'غير محدد';
}

String _extractSpecialty(String categoryString) {
  final specialty =
      categoryString.replaceFirst(RegExp(r'^\d+'), '').replaceFirst('_', '').trim();
  return specialty.isNotEmpty ? specialty : 'عام';
}

void _copyToClipboard(String text) {
  Clipboard.setData(ClipboardData(text: text));
  Get.snackbar('تم النسخ', 'تم نسخ النص بنجاح', snackPosition: SnackPosition.BOTTOM);
}
