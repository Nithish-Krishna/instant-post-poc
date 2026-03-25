import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../magic_post/presentation/widgets/result_post_card.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'History',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.surface,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .where('userId', isEqualTo: user.uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            print("FIRESTORE ERROR: ${snapshot.error}");
            return Center(
              child: Text(
                'Error loading history',
                style: GoogleFonts.inter(color: Colors.white70),
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return Center(
              child: Text(
                'No magical posts yet.\nStart generating!',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: Colors.white70, fontSize: 16),
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              return _buildGridItem(context, data);
            },
          );
        },
      ),
    );
  }

  Widget _buildGridItem(BuildContext context, Map<String, dynamic> data) {
    final imageUrl = data['imageUrl'] as String?;
    final music = data['musicChoice'] as String? ?? 'No music';
    final hasMusic = music.isNotEmpty && music != 'No music';

    return GestureDetector(
      onTap: () => _showDetailModal(context, data),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (imageUrl != null)
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                  if (wasSynchronouslyLoaded) return child;
                  return AnimatedOpacity(
                    opacity: frame == null ? 0 : 1,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    child: child,
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: AppColors.surface,
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => Container(
                  color: AppColors.surface,
                  child: const Center(
                    child: Icon(
                      LucideIcons.imageOff,
                      color: Colors.white54,
                      size: 24,
                    ),
                  ),
                ),
              )
            else
              Container(
                color: AppColors.surface,
                child: const Center(
                  child: Icon(
                    LucideIcons.imageOff,
                    color: Colors.white54,
                    size: 24,
                  ),
                ),
              ),
            if (hasMusic)
              Positioned(
                bottom: 8,
                right: 8,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      color: Colors.black.withOpacity(0.3),
                      child: const Icon(
                        LucideIcons.music,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showDetailModal(BuildContext context, Map<String, dynamic> data) {
    final imageUrl = data['imageUrl'] as String?;
    final caption = data['caption'] as String? ?? '';
    final music = data['musicChoice'] as String? ?? 'No music';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height,
          child: ResultPostCard(
            selectedImagePaths: const [],
            finalImageBytes: null,
            networkImageUrl: imageUrl,
            isDemoMode: false,
            generatedMusic: music,
            generatedCaption: caption,
            isFromHistory: true,
            onReset: () => Navigator.pop(context),
          ),
        );
      },
    );
  }
}
