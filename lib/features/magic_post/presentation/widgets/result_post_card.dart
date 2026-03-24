import 'dart:ui';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/bouncing_widget.dart';
import '../../../../downloader.dart' as downloader;

class ResultPostCard extends StatelessWidget {
  final List<String> selectedImagePaths;
  final Uint8List? finalImageBytes;
  final bool isDemoMode;
  final String generatedMusic;
  final String generatedCaption;
  final VoidCallback onReset;

  const ResultPostCard({
    super.key,
    required this.selectedImagePaths,
    this.finalImageBytes,
    required this.isDemoMode,
    required this.generatedMusic,
    required this.generatedCaption,
    required this.onReset,
  });

  void _showSuccessToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              LucideIcons.checkCircle2,
              color: AppColors.success,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              message,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.surfaceHighlight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showPostToInstagramDialog(BuildContext context) {
    HapticFeedback.lightImpact();
    final completedSteps = <int>{};

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Center(
            child: Container(
              width: 340,
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 40,
                    offset: const Offset(0, 20),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                LucideIcons.instagram,
                                color: AppColors.primary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Text(
                              "Post to Instagram",
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Icon(
                                LucideIcons.x,
                                color: Colors.white.withOpacity(0.3),
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _buildStepItem(
                          index: 1,
                          title: "Download Post Image",
                          subtitle: "Save to your photos",
                          icon: LucideIcons.download,
                          isCompleted: completedSteps.contains(1),
                          onTap: () async {
                            HapticFeedback.mediumImpact();
                            if (finalImageBytes != null) {
                              _showSuccessToast(context, "Saving to gallery...");
                              setDialogState(() => completedSteps.add(1));
                              await downloader.downloadBytes(finalImageBytes!, "magic_post_${DateTime.now().millisecondsSinceEpoch}.png");
                              _showSuccessToast(context, "Image saved successfully!");
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("No image available to download")),
                              );
                            }
                          },
                        ),
                        _buildStepItem(
                          index: 2,
                          title: "Copy Trending Music",
                          subtitle: generatedMusic,
                          icon: LucideIcons.copy,
                          isCompleted: completedSteps.contains(2),
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: generatedMusic));
                            _showSuccessToast(context, "Music copied to clipboard!");
                            setDialogState(() => completedSteps.add(2));
                          },
                        ),
                        _buildStepItem(
                          index: 3,
                          title: "Copy Perfect Caption",
                          subtitle: "Engagement optimized",
                          icon: LucideIcons.copy,
                          isCompleted: completedSteps.contains(3),
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: generatedCaption));
                            _showSuccessToast(context, "Caption copied to clipboard!");
                            setDialogState(() => completedSteps.add(3));
                          },
                        ),
                        _buildStepItem(
                          index: 4,
                          title: "Open Instagram",
                          subtitle: "Select 'Post'",
                          icon: LucideIcons.externalLink,
                          isCompleted: completedSteps.contains(4),
                          onTap: () async {
                            final uri = Uri.parse("https://instagram.com");
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri, mode: LaunchMode.externalApplication);
                              setDialogState(() => completedSteps.add(4));
                            }
                          },
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStepItem({
    required int index,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    bool isCompleted = false,
    bool isLast = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    index.toString(),
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 1.5,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            subtitle,
                            style: GoogleFonts.inter(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    BouncingWidget(
                      onTap: onTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white.withOpacity(0.08)),
                        ),
                        child: Icon(
                          isCompleted ? LucideIcons.checkCircle2 : icon,
                          color: isCompleted ? AppColors.success : Colors.white.withOpacity(0.7),
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<InlineSpan> _buildCaptionSpans(String text) {
    final List<InlineSpan> spans = [];
    final RegExp exp = RegExp(r"(#\w+)");
    final matches = exp.allMatches(text);

    int lastMatchEnd = 0;
    for (final match in matches) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(text: text.substring(lastMatchEnd, match.start)));
      }
      spans.add(
        TextSpan(
          text: match.group(0),
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
      lastMatchEnd = match.end;
    }
    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastMatchEnd)));
    }
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final List<String> displayImages = selectedImagePaths.isNotEmpty
        ? selectedImagePaths
        : ['assets/post2.png'];

    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            // 1. SCROLLABLE PREVIEW AREA
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 20,
                      right: 20,
                      top: 80,
                      bottom: 24,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Generated Post Container
                        Center(
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 400),
                            decoration: BoxDecoration(
                              color: const Color(0xFF000000),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.1),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Instagram Header
                                Padding(
                                  padding: const EdgeInsets.all(14.0),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 38,
                                        height: 38,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white.withOpacity(0.2),
                                            width: 1.5,
                                          ),
                                          image: const DecorationImage(
                                            image: AssetImage('assets/profile.jpg'),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  "thecrumbco",
                                                  style: GoogleFonts.inter(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                Image.asset(
                                                  'assets/check2.png',
                                                  width: 14,
                                                  height: 14,
                                                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.check_circle, size: 14, color: Colors.blue),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 2),
                                            Row(
                                              children: [
                                                const Icon(
                                                  LucideIcons.music,
                                                  color: Colors.white,
                                                  size: 11,
                                                ),
                                                const SizedBox(width: 5),
                                                Text(
                                                  generatedMusic,
                                                  style: GoogleFonts.inter(
                                                    color: Colors.white.withOpacity(0.7),
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Edit/Regenerate Controls
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              LucideIcons.refreshCw,
                                              color: Colors.white70,
                                              size: 18,
                                            ),
                                            onPressed: () {
                                              HapticFeedback.mediumImpact();
                                              _showSuccessToast(context, "Regenerating Post...");
                                            },
                                          ),
                                          const Icon(
                                            LucideIcons.moreVertical,
                                            color: Colors.white,
                                            size: 22,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ).animate().fadeIn(delay: 100.ms, duration: 600.ms).slideX(begin: -0.1, end: 0),

                                  AspectRatio(
                                    aspectRatio: 4 / 5,
                                    child: InteractiveViewer(
                                      minScale: 1.0,
                                      maxScale: 4.0,
                                      child: isDemoMode || finalImageBytes == null
                                          ? Image.asset(
                                              displayImages[0],
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey.withOpacity(0.2)),
                                            )
                                          : Image.memory(
                                              finalImageBytes!,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey.withOpacity(0.2)),
                                            ),
                                    ),
                                  ).animate().fadeIn(delay: 200.ms, duration: 800.ms).scale(
                                      begin: const Offset(0.95, 0.95),
                                      end: const Offset(1, 1),
                                    ),

                                // Actions
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14.0,
                                    vertical: 12.0,
                                  ),
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        'assets/like.png',
                                        width: 28,
                                        height: 28,
                                        color: Colors.white,
                                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.favorite_border, color: Colors.white),
                                      ).animate().fadeIn(delay: 400.ms, duration: 400.ms).scale(begin: const Offset(0, 0), end: const Offset(1, 1)),
                                      const SizedBox(width: 18),
                                      Image.asset(
                                        'assets/comment.png',
                                        width: 24,
                                        height: 24,
                                        color: Colors.white,
                                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.mode_comment_outlined, color: Colors.white),
                                      ).animate().fadeIn(delay: 500.ms, duration: 400.ms).scale(begin: const Offset(0, 0), end: const Offset(1, 1)),
                                      const SizedBox(width: 18),
                                      Image.asset(
                                        'assets/send.png',
                                        width: 24,
                                        height: 24,
                                        color: Colors.white,
                                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.send_outlined, color: Colors.white),
                                      ).animate().fadeIn(delay: 600.ms, duration: 400.ms).scale(begin: const Offset(0, 0), end: const Offset(1, 1)),
                                      const Spacer(),
                                      Image.asset(
                                        'assets/save.png',
                                        width: 28,
                                        height: 28,
                                        color: Colors.white,
                                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.bookmark_border, color: Colors.white),
                                      ).animate().fadeIn(delay: 700.ms, duration: 400.ms).scale(begin: const Offset(0, 0), end: const Offset(1, 1)),
                                    ],
                                  ),
                                ),

                                // Likes & Caption
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: SelectableText.rich(
                                              TextSpan(
                                                style: GoogleFonts.inter(
                                                  color: Colors.white,
                                                  fontSize: 13,
                                                  height: 1.5,
                                                ),
                                                children: [
                                                  const TextSpan(
                                                    text: "thecrumbco ",
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.w700,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    children: _buildCaptionSpans(generatedCaption),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ).animate().fadeIn(delay: 800.ms, duration: 600.ms),
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // 2. FIXED BOTTOM ACTION BAR (Glassmorphism)
            ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, -5),
                      ),
                    ],
                    border: Border(
                      top: BorderSide(color: Colors.white.withOpacity(0.05)),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Post Button
                        BouncingWidget(
                          onTap: () => _showPostToInstagramDialog(context),
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 400),
                            height: 56,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: const LinearGradient(
                                colors: [AppColors.primary, AppColors.primaryLight],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    LucideIcons.instagram,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    "Post to Instagram",
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ).animate().fadeIn(delay: 900.ms, duration: 600.ms),
                        const SizedBox(height: 12),

                        // Back Button
                        TextButton(
                          onPressed: onReset,
                          child: Text(
                            "Create Another",
                            style: GoogleFonts.inter(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
