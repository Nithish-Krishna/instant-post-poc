import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:instant_post_poc/features/magic_post/presentation/widgets/input_section.dart';
import 'package:instant_post_poc/features/magic_post/presentation/widgets/loading_skeleton.dart';
import 'package:instant_post_poc/features/magic_post/presentation/widgets/result_post_card.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../data/magic_post_repository.dart';

import '../../../../core/config/app_environment.dart';
import '../../../../core/constants/mock_data.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/bouncing_widget.dart';
import '../../../credit_system/presentation/widgets/credit_top_bar.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import '../../../../features/auth/user_service.dart';
import 'dart:ui';
import '../../../history/presentation/screens/history_screen.dart';
import '../../../profile/presentation/screens/settings_screen.dart';
import '../../../profile/presentation/screens/about_screen.dart';

enum AppState { input, loading, result }

class MagicGeneratorScreen extends StatefulWidget {
  const MagicGeneratorScreen({super.key});

  @override
  State<MagicGeneratorScreen> createState() => _MagicGeneratorScreenState();
}

class _MagicGeneratorScreenState extends State<MagicGeneratorScreen>
    with TickerProviderStateMixin {
  AppState _currentState = AppState.input;

  // AI Credit System State
  final int _costPerGeneration = 2;
  final UserService _userService = UserService();

  // UI State
  String _selectedTone = MockData.tones[0];
  int _loadingTextIndex = 0;
  Timer? _loadingTimer;
  final TextEditingController _textController = TextEditingController();
  final FocusNode _inputFocusNode = FocusNode();
  List<String> _selectedImagePaths = [];
  int _promptIndex = 0;

  // Added Gen Output State
  Uint8List? _finalImageBytes;
  String _generatedCaption = MockData.generatedCaption;
  String _generatedMusic = MockData.generatedMusic;
  final MagicPostRepository _repository = MagicPostRepository();

  @override
  void initState() {
    super.initState();
    _inputFocusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _loadingTimer?.cancel();
    _textController.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  void _startGeneration(List<Uint8List> images, String prompt, String tone) async {
    if (prompt.isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final creditsStream = await _userService.getUserCredits(user.uid).first;
      if (creditsStream < _costPerGeneration) {
        HapticFeedback.heavyImpact();
        _showOutOfCreditsDialog();
        return;
      }
    }

    HapticFeedback.mediumImpact();
    FocusScope.of(context).unfocus();

    setState(() {
      _currentState = AppState.loading;
      _loadingTextIndex = 0;
    });

    final isDemoMode = context.read<AppEnvironment>().isDemoMode;

    if (isDemoMode) {
      // Demo Mode: Mock delay and data
      _loadingTimer = Timer.periodic(const Duration(milliseconds: 900), (
        timer,
      ) {
        if (!mounted) return;
        setState(() {
          _loadingTextIndex =
              (_loadingTextIndex + 1) % MockData.loadingTexts.length;
        });
      });

      Future.delayed(const Duration(seconds: 4), () {
        if (!mounted) return;
        _loadingTimer?.cancel();
        setState(() {
          _finalImageBytes = null;
          _generatedCaption = MockData.generatedCaption;
          _generatedMusic = MockData.generatedMusic;
          _currentState = AppState.result;
        });
      });
    } else {
      // Production Mode
      _loadingTimer = Timer.periodic(const Duration(milliseconds: 900), (timer) {
        if (!mounted) return;
        setState(() {
          _loadingTextIndex = (_loadingTextIndex + 1) % MockData.loadingTexts.length;
        });
      });

      try {
        final result = await _repository.generatePost(
          prompt: prompt,
          tone: tone,
          images: images,
        );

        if (!mounted) return;

        final base64Image = result['generatedImage'] as String;
        final caption = result['caption'] as String;
        final music = result['musicChoice'] as String;
        final imageBytes = base64Decode(base64Image);

        // Upload to Storage
        final currentUser = FirebaseAuth.instance.currentUser!;
        final postId = const Uuid().v4();
        final storageRef = FirebaseStorage.instance.ref().child('posts/${currentUser.uid}/$postId.jpg');
        await storageRef.putData(imageBytes, SettableMetadata(contentType: 'image/jpeg'));
        final downloadUrl = await storageRef.getDownloadURL();

        // Save to Firestore
        await FirebaseFirestore.instance.collection('posts').doc(postId).set({
          'userId': currentUser.uid,
          'imageUrl': downloadUrl,
          'caption': caption,
          'musicChoice': music,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Deduct Credit
        await _userService.deductCredit(currentUser.uid, _costPerGeneration);

        _loadingTimer?.cancel();
        if (!mounted) return;
        
        setState(() {
          _finalImageBytes = imageBytes;
          _generatedCaption = caption;
          _generatedMusic = music;
          _currentState = AppState.result;
        });
      } catch (e) {
        if (!mounted) return;
        _loadingTimer?.cancel();
        _showSuccessToast("Error: ${e.toString()}");
        setState(() {
          _currentState = AppState.input;
        });
      }
    }
  }

  void _reset() {
    HapticFeedback.lightImpact();
    setState(() {
      _currentState = AppState.input;
      _textController.clear();
      _selectedImagePaths = [];
    });
  }

  void _showSuccessToast(String message) {
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
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
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

  PopupMenuItem<String> _buildPopupItem(IconData icon, String title) {
    return PopupMenuItem<String>(
      value: title,
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 18),
          const SizedBox(width: 12),
          Text(
            title,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showOutOfCreditsDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.zap,
                color: AppColors.warning,
                size: 32,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Out of AI Credits",
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "You need $_costPerGeneration credits to generate a post. Refill your balance to keep creating magic.",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 15,
                color: Colors.white70,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            BouncingWidget(
              onTap: () async {
                HapticFeedback.mediumImpact();
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                   await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
                     'credits': FieldValue.increment(20)
                   });
                }
                if (mounted) Navigator.pop(context);
                _showSuccessToast("20 AI Credits added!");
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryLight],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    "Refill 20 Credits (\$4.99)",
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentState() {
    switch (_currentState) {
      case AppState.input:
        return InputSection(
          key: const ValueKey('input'),
          textController: _textController,
          inputFocusNode: _inputFocusNode,
          selectedTone: _selectedTone,
          onToneChanged: (tone) {
            HapticFeedback.selectionClick();
            setState(() => _selectedTone = tone);
          },
          onPromptWand: () {
            HapticFeedback.selectionClick();
            setState(() {
              _textController.text = MockData.examplePrompts[_promptIndex];
              _promptIndex =
                  (_promptIndex + 1) % MockData.examplePrompts.length;
            });
          },
          onGenerate: _startGeneration,
          costPerGeneration: _costPerGeneration,
        );
      case AppState.loading:
        return LoadingSkeleton(
          key: const ValueKey('loading'),
          loadingTextIndex: _loadingTextIndex,
        );
      case AppState.result:
        return ResultPostCard(
          key: const ValueKey('result'),
          selectedImagePaths: _selectedImagePaths,
          finalImageBytes: _finalImageBytes,
          isDemoMode: context.read<AppEnvironment>().isDemoMode,
          generatedMusic: _generatedMusic,
          generatedCaption: _generatedCaption,
          onReset: _reset,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          const CreditTopBar(),
          PopupMenuButton<String>(
            icon: const Icon(LucideIcons.menu, color: Colors.white),
            color: AppColors.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            offset: const Offset(0, 50),
            elevation: 8,
            popUpAnimationStyle: AnimationStyle(
              duration: Duration.zero,
              reverseDuration: Duration.zero,
            ),
            onSelected: (value) {
              if (value == 'History') {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen()));
              } else if (value == 'Settings') {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
              } else if (value == 'Tutorial') {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tutorial coming soon!')));
              } else if (value == 'About') {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen()));
              }
            },
            itemBuilder: (context) => [
              _buildPopupItem(LucideIcons.history, 'History'),
              _buildPopupItem(LucideIcons.settings, 'Settings'),
              _buildPopupItem(LucideIcons.playCircle, 'Tutorial'),
              _buildPopupItem(LucideIcons.info, 'About'),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 600),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: _buildCurrentState(),
        ),
      ),
    );
  }
}
