import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:instant_post_poc/features/magic_post/presentation/widgets/input_section.dart';
import 'package:instant_post_poc/features/magic_post/presentation/widgets/loading_skeleton.dart';
import 'package:instant_post_poc/features/magic_post/presentation/widgets/result_post_card.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../../core/config/app_environment.dart';
import '../../../../core/constants/mock_data.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/bouncing_widget.dart';
import '../../../credit_system/presentation/widgets/credit_top_bar.dart';

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
  int _aiCredits = 12;
  final int _costPerGeneration = 2;

  // UI State
  String _selectedTone = MockData.tones[0];
  int _loadingTextIndex = 0;
  Timer? _loadingTimer;
  final TextEditingController _textController = TextEditingController();
  final FocusNode _inputFocusNode = FocusNode();
  List<String> _selectedImagePaths = [];
  int _promptIndex = 0;

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

  void _startGeneration() {
    if (_textController.text.isEmpty) return;

    if (_aiCredits < _costPerGeneration) {
      HapticFeedback.heavyImpact();
      _showOutOfCreditsDialog();
      return;
    }

    HapticFeedback.mediumImpact();
    FocusScope.of(context).unfocus();

    setState(() {
      _aiCredits -= _costPerGeneration;
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
          _currentState = AppState.result;
        });
      });
    } else {
      // Production Mode
      // TODO: Implement real API call here (ensure backend handles CORS for Flutter Web).
      // For now, simulate delay then go to result.
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        setState(() {
          _currentState = AppState.result;
        });
      });
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
              onTap: () {
                HapticFeedback.mediumImpact();
                setState(() => _aiCredits += 20); // Dummy refill
                Navigator.pop(context);
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
          generatedMusic: MockData.generatedMusic,
          generatedCaption: MockData.generatedCaption,
          onReset: _reset,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: _buildCurrentState(),
            ),
            // Persistent Credit Bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: CreditTopBar(aiCredits: _aiCredits),
            ),
          ],
        ),
      ),
    );
  }
}
