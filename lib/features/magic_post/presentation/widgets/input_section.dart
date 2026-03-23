import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/bouncing_widget.dart';
import '../../../../core/constants/mock_data.dart';

class InputSection extends StatefulWidget {
  final TextEditingController textController;
  final FocusNode inputFocusNode;
  final String selectedTone;
  final List<String> selectedImagePaths;
  final VoidCallback onImageSelect;
  final VoidCallback onImageRemove;
  final ValueChanged<String> onToneChanged;
  final VoidCallback onPromptWand;
  final VoidCallback onGenerate;
  final int costPerGeneration;

  const InputSection({
    super.key,
    required this.textController,
    required this.inputFocusNode,
    required this.selectedTone,
    required this.selectedImagePaths,
    required this.onImageSelect,
    required this.onImageRemove,
    required this.onToneChanged,
    required this.onPromptWand,
    required this.onGenerate,
    required this.costPerGeneration,
  });

  @override
  State<InputSection> createState() => _InputSectionState();
}

class _InputSectionState extends State<InputSection> {
  int _hintIndex = 0;
  // Timer could be managed here if needed, but since parent can rebuild the layout, 
  // we'll keep the timer logic in parent or let input section manage its own hint index.
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 80,
                  bottom: 24,
                ), // Added top padding for floating bar
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryLight],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        LucideIcons.sparkles,
                        color: Colors.white,
                        size: 40,
                      ),
                    ).animate().fadeIn(duration: 600.ms).scale(
                          begin: const Offset(0.8, 0.8),
                          end: const Offset(1, 1),
                        ),
                    const SizedBox(height: 24),
                    // Title
                    Text(
                      "InstantPost AI",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideY(begin: 0.1, end: 0),
                    const SizedBox(height: 12),
                    // Subtitle
                    Text(
                      "Create viral Instagram posts in seconds with AI",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.5),
                        height: 1.5,
                      ),
                    ).animate().fadeIn(delay: 300.ms, duration: 600.ms).slideY(begin: 0.1, end: 0),
                    const SizedBox(height: 48),
                    // Chat input container
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          constraints: const BoxConstraints(maxWidth: 600),
                          decoration: BoxDecoration(
                            color: AppColors.surface.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: widget.inputFocusNode.hasFocus
                                  ? AppColors.primary.withOpacity(0.3)
                                  : Colors.white.withOpacity(0.08),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Image Preview Area
                              if (widget.selectedImagePaths.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 16,
                                    left: 16,
                                    right: 16,
                                  ),
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    physics: const BouncingScrollPhysics(),
                                    child: Row(
                                      children: widget.selectedImagePaths.map((path) {
                                        return Padding(
                                          padding: const EdgeInsets.only(right: 12),
                                          child: Stack(
                                            children: [
                                              Container(
                                                height: 80,
                                                width: 80,
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(12),
                                                  image: DecorationImage(
                                                    image: AssetImage(path),
                                                    fit: BoxFit.cover,
                                                  ),
                                                  border: Border.all(
                                                    color: Colors.white.withOpacity(0.1),
                                                  ),
                                                ),
                                              ).animate().scale(
                                                    begin: const Offset(0.8, 0.8),
                                                    end: const Offset(1, 1),
                                                    curve: Curves.easeOutBack,
                                                  ).fadeIn(),
                                              Positioned(
                                                top: -4,
                                                right: -4,
                                                child: GestureDetector(
                                                  onTap: widget.onImageRemove,
                                                  child: Container(
                                                    padding: const EdgeInsets.all(4),
                                                    decoration: const BoxDecoration(
                                                      color: Colors.black54,
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: const Icon(
                                                      LucideIcons.x,
                                                      color: Colors.white,
                                                      size: 14,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              // Input field
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Image attachment icon
                                    BouncingWidget(
                                      onTap: widget.onImageSelect,
                                      child: Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.06),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          LucideIcons.image,
                                          color: Colors.white.withOpacity(0.6),
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    // Text field
                                    Expanded(
                                      child: ConstrainedBox(
                                        constraints: const BoxConstraints(
                                          maxHeight: 120,
                                        ),
                                        child: TextField(
                                          controller: widget.textController,
                                          focusNode: widget.inputFocusNode,
                                          maxLines: null,
                                          minLines: 1,
                                          maxLength: 2200,
                                          buildCounter: (
                                            context, {
                                            required currentLength,
                                            required isFocused,
                                            maxLength,
                                          }) =>
                                              null, // Hide default counter
                                          style: GoogleFonts.inter(
                                            color: Colors.white,
                                            fontSize: 15,
                                            height: 1.5,
                                          ),
                                          decoration: InputDecoration(
                                            hintText: MockData.hintPrompts[_hintIndex], // Uses simple 0 for now
                                            hintStyle: GoogleFonts.inter(
                                              color: Colors.white.withOpacity(0.3),
                                              fontSize: 15,
                                            ),
                                            filled: false,
                                            border: InputBorder.none,
                                            contentPadding: const EdgeInsets.symmetric(
                                              horizontal: 0,
                                              vertical: 12,
                                            ),
                                          ),
                                          onTap: () => HapticFeedback.selectionClick(),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    // Mic icon
                                    BouncingWidget(
                                      onTap: () {
                                        HapticFeedback.selectionClick();
                                      },
                                      child: Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.06),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          LucideIcons.mic,
                                          color: Colors.white.withOpacity(0.6),
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Tone Selector
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 16,
                                  bottom: 12,
                                ),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  child: Row(
                                    children: MockData.tones.map((tone) => Padding(
                                            padding: const EdgeInsets.only(right: 8),
                                            child: GestureDetector(
                                              onTap: () => widget.onToneChanged(tone),
                                              child: AnimatedContainer(
                                                duration: const Duration(milliseconds: 200),
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 14,
                                                  vertical: 6,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: widget.selectedTone == tone
                                                      ? AppColors.primary.withOpacity(0.2)
                                                      : Colors.white.withOpacity(0.05),
                                                  borderRadius: BorderRadius.circular(20),
                                                  border: Border.all(
                                                    color: widget.selectedTone == tone
                                                        ? AppColors.primary.withOpacity(0.5)
                                                        : Colors.transparent,
                                                  ),
                                                ),
                                                child: Text(
                                                  tone,
                                                  style: GoogleFonts.inter(
                                                    color: widget.selectedTone == tone
                                                        ? Colors.white
                                                        : Colors.white54,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ).toList(),
                                  ),
                                ),
                              ),
                              // Divider & Bottom Action
                              Container(
                                height: 1,
                                color: Colors.white.withOpacity(0.06),
                              ),
                              // Bottom action bar
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 16,
                                  right: 12,
                                  top: 12,
                                  bottom: 12,
                                ),
                                child: Row(
                                  children: [
                                    BouncingWidget(
                                      onTap: widget.onPromptWand,
                                      child: SizedBox(
                                        width: 44,
                                        height: 44,
                                        child: Center(
                                          child: Icon(
                                            LucideIcons.wand2,
                                            color: Colors.white.withOpacity(0.4),
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // Character limit
                                    ValueListenableBuilder(
                                      valueListenable: widget.textController,
                                      builder: (context, value, child) {
                                        return Text(
                                          "${widget.textController.text.length}/2200",
                                          style: GoogleFonts.inter(
                                            color: Colors.white.withOpacity(0.3),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        );
                                      }
                                    ),
                                    const Spacer(),
                                    // Generate button
                                    ValueListenableBuilder(
                                      valueListenable: widget.textController,
                                      builder: (context, value, child) {
                                        return IgnorePointer(
                                          ignoring: widget.textController.text.isEmpty,
                                          child: BouncingWidget(
                                            onTap: widget.onGenerate,
                                            child: AnimatedOpacity(
                                              duration: const Duration(milliseconds: 200),
                                              opacity: widget.textController.text.isEmpty ? 0.5 : 1.0,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 20,
                                                  vertical: 12,
                                                ),
                                                decoration: BoxDecoration(
                                                  gradient: const LinearGradient(
                                                    colors: [
                                                      AppColors.primary,
                                                      AppColors.primaryLight,
                                                    ],
                                                  ),
                                                  borderRadius: BorderRadius.circular(14),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: AppColors.primary.withOpacity(0.4),
                                                      blurRadius: 12,
                                                      offset: const Offset(0, 4),
                                                    ),
                                                  ],
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      "Generate",
                                                      style: GoogleFonts.inter(
                                                        color: Colors.white,
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 2,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.black.withOpacity(0.2),
                                                        borderRadius: BorderRadius.circular(6),
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          const Icon(
                                                            LucideIcons.zap,
                                                            color: AppColors.warning,
                                                            size: 12,
                                                          ),
                                                          const SizedBox(width: 4),
                                                          Text(
                                                            "${widget.costPerGeneration}",
                                                            style: GoogleFonts.inter(
                                                              color: Colors.white,
                                                              fontSize: 12,
                                                              fontWeight: FontWeight.w700,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ).animate().fadeIn(delay: 400.ms, duration: 600.ms).slideY(begin: 0.1, end: 0),
                    const SizedBox(height: 32),
                    Text(
                      "Developed by Nithish",
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.3),
                        fontWeight: FontWeight.w500,
                      ),
                    ).animate().fadeIn(delay: 600.ms, duration: 600.ms),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
