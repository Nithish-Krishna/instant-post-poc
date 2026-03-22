// DEPENDENCIES - Add these to your pubspec.yaml:
//
// dependencies:
//   flutter:
//     sdk: flutter
//   google_fonts: ^6.1.0
//   flutter_animate: ^4.5.0
//   shimmer: ^3.0.0
//   lucide_icons: ^0.0.4

import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'downloader.dart' as dl;

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const AIMagicApp());
}

class AIMagicApp extends StatelessWidget {
  const AIMagicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Instagram Generator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0D1C),
        fontFamily: GoogleFonts.inter().fontFamily,
        primaryColor: const Color(0xFF6366F1),
        useMaterial3: true,
      ),
      home: const MagicGeneratorScreen(),
    );
  }
}

enum AppState { input, loading, result }

class MagicGeneratorScreen extends StatefulWidget {
  const MagicGeneratorScreen({super.key});

  @override
  State<MagicGeneratorScreen> createState() => _MagicGeneratorScreenState();
}

class _MagicGeneratorScreenState extends State<MagicGeneratorScreen>
    with TickerProviderStateMixin {
  AppState _currentState = AppState.input;
  int _loadingTextIndex = 0;
  Timer? _loadingTimer;
  final TextEditingController _textController = TextEditingController();
  final FocusNode _inputFocusNode = FocusNode();
  List<String> _selectedImagePaths = [];
  int _promptIndex = 0;
  int _hintIndex = 0;
  Timer? _hintTimer;

  String _generatedCaption =
      "Something new just dropped ✨🍰\n\n"
      "Our summer menu is here — iced coffees ☕, fresh croissants 🥐 & desserts made for chill days 🍃\n\n"
      "Enjoy 10% off this weekend 💸 Pull up 📍\n\n"
      "#SummerMenu #CafeVibes #DessertDrop #ColdCoffee #WeekendPlans";
  String _generatedMusic = "Golden Hour";

  final List<String> _examplePrompts = [
    "New summer menu, 10% off this weekend",
  ];

  final List<String> _hintPrompts = [
    "Describe your Instagram post...",
    "A cinematic shot of my pet cat...",
    "Midnight street photography in Tokyo...",
    "A delicious homemade pasta recipe...",
    "My summer trip to the Amalfi Coast...",
  ];

  final List<String> _loadingTexts = [
    "Analyzing your idea...",
    "Choosing the perfect music...",
    "Designing your post...",
    "Crafting a high-engagement caption...",
    "Applying final touches...",
  ];

  @override
  void initState() {
    super.initState();
    _inputFocusNode.addListener(() {
      setState(() {});
    });
    _startHintTimer();
  }

  void _startHintTimer() {
    _hintTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) return;
      setState(() {
        _hintIndex = (_hintIndex + 1) % _hintPrompts.length;
      });
    });
  }

  @override
  void dispose() {
    _loadingTimer?.cancel();
    _hintTimer?.cancel();
    _textController.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  void _startGeneration() {
    if (_textController.text.isEmpty) return;

    HapticFeedback.mediumImpact();
    FocusScope.of(context).unfocus();

    setState(() {
      _currentState = AppState.loading;
      _loadingTextIndex = 0;
    });

    // Clear inputs after starting generation
    _textController.clear();
    setState(() {
      _selectedImagePaths = [];
    });

    _loadingTimer = Timer.periodic(const Duration(milliseconds: 900), (timer) {
      if (!mounted) return;
      setState(() {
        _loadingTextIndex = (_loadingTextIndex + 1) % _loadingTexts.length;
      });
    });

    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;
      _loadingTimer?.cancel();
      setState(() {
        _currentState = AppState.result;
      });
    });
  }

  void _reset() {
    HapticFeedback.lightImpact();
    setState(() {
      _currentState = AppState.input;
      _textController.clear();
      _selectedImagePaths = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFF0A0D1C),
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

  Widget _buildCurrentState() {
    switch (_currentState) {
      case AppState.input:
        return _buildInputUI(key: const ValueKey('input'));
      case AppState.loading:
        return _buildLoadingUI(key: const ValueKey('loading'));
      case AppState.result:
        return _buildResultUI(key: const ValueKey('result'));
    }
  }

  Widget _buildInputUI({required Key key}) {
    return LayoutBuilder(
      key: key,
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
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
                              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6366F1).withOpacity(0.3),
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
                        )
                        .animate()
                        .fadeIn(duration: 600.ms)
                        .scale(
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
                        )
                        .animate()
                        .fadeIn(delay: 200.ms, duration: 600.ms)
                        .slideY(begin: 0.1, end: 0),
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
                        )
                        .animate()
                        .fadeIn(delay: 300.ms, duration: 600.ms)
                        .slideY(begin: 0.1, end: 0),
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
                                color: const Color(0xFF141829).withOpacity(0.7),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: _inputFocusNode.hasFocus
                                      ? const Color(0xFF6366F1).withOpacity(0.3)
                                      : Colors.white.withOpacity(0.08),
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Image Preview Area
                                  if (_selectedImagePaths.isNotEmpty)
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
                                          children: _selectedImagePaths.map((
                                            path,
                                          ) {
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                right: 12,
                                              ),
                                              child: Stack(
                                                children: [
                                                  Container(
                                                        height: 80,
                                                        width: 80,
                                                        decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12,
                                                              ),
                                                          image:
                                                              DecorationImage(
                                                                image:
                                                                    AssetImage(
                                                                      path,
                                                                    ),
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                          border: Border.all(
                                                            color: Colors.white
                                                                .withOpacity(
                                                                  0.1,
                                                                ),
                                                          ),
                                                        ),
                                                      )
                                                      .animate()
                                                      .scale(
                                                        begin: const Offset(
                                                          0.8,
                                                          0.8,
                                                        ),
                                                        end: const Offset(1, 1),
                                                        curve:
                                                            Curves.easeOutBack,
                                                      )
                                                      .fadeIn(),
                                                  Positioned(
                                                    top: -4,
                                                    right: -4,
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        HapticFeedback.lightImpact();
                                                        setState(() {
                                                          _selectedImagePaths
                                                              .remove(path);
                                                        });
                                                      },
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets.all(
                                                              4,
                                                            ),
                                                        decoration:
                                                            const BoxDecoration(
                                                              color: Colors
                                                                  .black54,
                                                              shape: BoxShape
                                                                  .circle,
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        // Image attachment icon
                                        BouncingWidget(
                                          onTap: () {
                                            HapticFeedback.selectionClick();
                                            setState(() {
                                              _selectedImagePaths = [
                                                'assets/cupcake.png',
                                                'assets/coffee.png',
                                                'assets/crossiant.png',
                                              ];
                                            });
                                          },
                                          child: Container(
                                            width: 44,
                                            height: 44,
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(
                                                0.06,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Icon(
                                              LucideIcons.image,
                                              color: Colors.white.withOpacity(
                                                0.6,
                                              ),
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
                                              controller: _textController,
                                              focusNode: _inputFocusNode,
                                              maxLines: null,
                                              minLines: 1,
                                              onChanged: (val) {
                                                setState(() {});
                                              },
                                              style: GoogleFonts.inter(
                                                color: Colors.white,
                                                fontSize: 15,
                                                height: 1.5,
                                              ),
                                              decoration: InputDecoration(
                                                hintText:
                                                    _hintPrompts[_hintIndex],
                                                hintStyle: GoogleFonts.inter(
                                                  color: Colors.white
                                                      .withOpacity(0.3),
                                                  fontSize: 15,
                                                ),
                                                filled: false,
                                                border: InputBorder.none,
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 0,
                                                      vertical: 12,
                                                    ),
                                              ),
                                              onTap: () =>
                                                  HapticFeedback.selectionClick(),
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
                                              color: Colors.white.withOpacity(
                                                0.06,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Icon(
                                              LucideIcons.mic,
                                              color: Colors.white.withOpacity(
                                                0.6,
                                              ),
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Divider
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
                                          onTap: () {
                                            HapticFeedback.selectionClick();
                                            setState(() {
                                              _textController.text =
                                                  _examplePrompts[_promptIndex];
                                              _promptIndex =
                                                  (_promptIndex + 1) %
                                                  _examplePrompts.length;
                                            });
                                          },
                                          child: SizedBox(
                                            width: 44,
                                            height: 44,
                                            child: Center(
                                              child: Icon(
                                                LucideIcons.wand2,
                                                color: Colors.white.withOpacity(
                                                  0.4,
                                                ),
                                                size: 20,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const Spacer(),
                                        // Generate button
                                        IgnorePointer(
                                          ignoring:
                                              _textController.text.isEmpty,
                                          child: BouncingWidget(
                                            onTap: _startGeneration,
                                            child: AnimatedOpacity(
                                              duration: const Duration(
                                                milliseconds: 200,
                                              ),
                                              opacity:
                                                  _textController.text.isEmpty
                                                  ? 0.5
                                                  : 1.0,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 24,
                                                      vertical: 12,
                                                    ),
                                                decoration: BoxDecoration(
                                                  gradient:
                                                      const LinearGradient(
                                                        colors: [
                                                          Color(0xFF6366F1),
                                                          Color(0xFF8B5CF6),
                                                        ],
                                                      ),
                                                  borderRadius:
                                                      BorderRadius.circular(14),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: const Color(
                                                        0xFF6366F1,
                                                      ).withOpacity(0.4),
                                                      blurRadius: 12,
                                                      offset: const Offset(
                                                        0,
                                                        4,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      "Generate Post",
                                                      style: GoogleFonts.inter(
                                                        color: Colors.white,
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    const Icon(
                                                      LucideIcons.arrowUp,
                                                      color: Colors.white,
                                                      size: 18,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                        .animate()
                        .fadeIn(delay: 400.ms, duration: 600.ms)
                        .slideY(begin: 0.1, end: 0),
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

  Widget _buildLoadingUI({required Key key}) {
    return LayoutBuilder(
      key: key,
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildPostSkeleton(),
                    const SizedBox(height: 32),
                    // Loading text and dots
                    Column(
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          child: Text(
                            _loadingTexts[_loadingTextIndex],
                            key: ValueKey<String>(
                              _loadingTexts[_loadingTextIndex],
                            ),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              color: const Color(0xFF6366F1),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            3,
                            (index) =>
                                Container(
                                      width: 8,
                                      height: 8,
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF6366F1),
                                        shape: BoxShape.circle,
                                      ),
                                    )
                                    .animate(
                                      onPlay: (controller) =>
                                          controller.repeat(),
                                    )
                                    .fadeOut(
                                      delay: (index * 200).ms,
                                      duration: 600.ms,
                                    )
                                    .then()
                                    .fadeIn(duration: 600.ms),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPostSkeleton() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        color: const Color(0xFF141829),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                _shimmerBox(width: 38, height: 38, shape: BoxShape.circle),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _shimmerBox(width: 120, height: 12),
                    const SizedBox(height: 6),
                    _shimmerBox(width: 80, height: 10),
                  ],
                ),
              ],
            ),
          ),
          // Image
          AspectRatio(
            aspectRatio: 4 / 5,
            child: Shimmer.fromColors(
              baseColor: const Color(0xFF1E2235),
              highlightColor: const Color(0xFF2A2F45),
              child: Container(
                decoration: const BoxDecoration(color: Colors.white),
              ),
            ),
          ),
          // Actions and caption
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: List.generate(
                    3,
                    (index) => Padding(
                      padding: const EdgeInsets.only(right: 14),
                      child: _shimmerBox(
                        width: 24,
                        height: 24,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                _shimmerBox(width: double.infinity, height: 12),
                const SizedBox(height: 8),
                _shimmerBox(width: 200, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _shimmerBox({
    required double width,
    required double height,
    BoxShape shape = BoxShape.rectangle,
  }) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFF1E2235),
      highlightColor: const Color(0xFF2A2F45),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: shape,
          borderRadius: shape == BoxShape.rectangle
              ? BorderRadius.circular(6)
              : null,
        ),
      ),
    );
  }

  Widget _buildResultUI({required Key key}) {
    return LayoutBuilder(
      key: key,
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
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
                                            color: Colors.white.withOpacity(
                                              0.2,
                                            ),
                                            width: 1.5,
                                          ),
                                          image: const DecorationImage(
                                            image: AssetImage(
                                              'assets/profile.jpg',
                                            ),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
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
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 2),
                                            Row(
                                              children: [
                                                Icon(
                                                  LucideIcons.music,
                                                  color: Colors.white,
                                                  size: 11,
                                                ),
                                                const SizedBox(width: 5),
                                                Text(
                                                  _generatedMusic,
                                                  style: GoogleFonts.inter(
                                                    color: Colors.white
                                                        .withOpacity(0.7),
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(
                                        LucideIcons.moreVertical,
                                        color: Colors.white,
                                        size: 22,
                                      ),
                                    ],
                                  ),
                                )
                                .animate()
                                .fadeIn(delay: 100.ms, duration: 600.ms)
                                .slideX(begin: -0.1, end: 0),
                            // Image
                            AspectRatio(
                                  aspectRatio: 4 / 5,
                                  child: Image.asset(
                                    'assets/post2.png',
                                    fit: BoxFit.cover,
                                  ),
                                )
                                .animate()
                                .fadeIn(delay: 200.ms, duration: 800.ms)
                                .scale(
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
                                      )
                                      .animate()
                                      .fadeIn(delay: 400.ms, duration: 400.ms)
                                      .scale(
                                        begin: const Offset(0, 0),
                                        end: const Offset(1, 1),
                                      ),
                                  const SizedBox(width: 18),
                                  Image.asset(
                                        'assets/comment.png',
                                        width: 24,
                                        height: 24,
                                        color: Colors.white,
                                      )
                                      .animate()
                                      .fadeIn(delay: 500.ms, duration: 400.ms)
                                      .scale(
                                        begin: const Offset(0, 0),
                                        end: const Offset(1, 1),
                                      ),
                                  const SizedBox(width: 18),
                                  Image.asset(
                                        'assets/send.png',
                                        width: 24,
                                        height: 24,
                                        color: Colors.white,
                                      )
                                      .animate()
                                      .fadeIn(delay: 600.ms, duration: 400.ms)
                                      .scale(
                                        begin: const Offset(0, 0),
                                        end: const Offset(1, 1),
                                      ),
                                  const Spacer(),
                                  Image.asset(
                                        'assets/save.png',
                                        width: 28,
                                        height: 28,
                                        color: Colors.white,
                                      )
                                      .animate()
                                      .fadeIn(delay: 700.ms, duration: 400.ms)
                                      .scale(
                                        begin: const Offset(0, 0),
                                        end: const Offset(1, 1),
                                      ),
                                ],
                              ),
                            ),
                            // Likes & Caption
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Removed "Liked by" section
                                  RichText(
                                    text: TextSpan(
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
                                            children: _buildCaptionSpans(
                                              _generatedCaption,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ).animate().fadeIn(delay: 800.ms, duration: 600.ms),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Post Button
                    BouncingWidget(
                      onTap: () => _showPostToInstagramDialog(context),
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 400),
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6366F1).withOpacity(0.4),
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
                    const SizedBox(height: 32),
                    // Back Button
                    TextButton(
                      onPressed: _reset,
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
        );
      },
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
                color: const Color(0xFF141829),
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
                                color: const Color(0xFF6366F1).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                LucideIcons.instagram,
                                color: Color(0xFF6366F1),
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
                            await dl.downloadAsset(
                              "assets/post2.png",
                              "my_instagram_post.png",
                            );
                            setDialogState(() => completedSteps.add(1));
                            Future.delayed(const Duration(seconds: 2), () {
                              if (context.mounted) {
                                setDialogState(() => completedSteps.remove(1));
                              }
                            });
                          },
                        ),
                        _buildStepItem(
                          index: 2,
                          title: "Copy Trending Music",
                          subtitle: _generatedMusic,
                          icon: LucideIcons.copy,
                          isCompleted: completedSteps.contains(2),
                          onTap: () {
                            Clipboard.setData(
                              ClipboardData(text: _generatedMusic),
                            );
                            setDialogState(() => completedSteps.add(2));
                            Future.delayed(const Duration(seconds: 2), () {
                              if (context.mounted) {
                                setDialogState(() => completedSteps.remove(2));
                              }
                            });
                          },
                        ),
                        _buildStepItem(
                          index: 3,
                          title: "Copy Perfect Caption",
                          subtitle: "Engagement optimized",
                          icon: LucideIcons.copy,
                          isCompleted: completedSteps.contains(3),
                          onTap: () {
                            Clipboard.setData(
                              ClipboardData(text: _generatedCaption),
                            );
                            setDialogState(() => completedSteps.add(3));
                            Future.delayed(const Duration(seconds: 2), () {
                              if (context.mounted) {
                                setDialogState(() => completedSteps.remove(3));
                              }
                            });
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
                              await launchUrl(
                                uri,
                                mode: LaunchMode.externalApplication,
                              );
                              setDialogState(() => completedSteps.add(4));
                              Future.delayed(const Duration(seconds: 2), () {
                                if (context.mounted) {
                                  setDialogState(
                                    () => completedSteps.remove(4),
                                  );
                                }
                              });
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
                  color: Color(0xFF6366F1),
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.08),
                          ),
                        ),
                        child: Icon(
                          isCompleted ? LucideIcons.checkCircle2 : icon,
                          color: isCompleted
                              ? const Color(0xFF10B981)
                              : Colors.white.withOpacity(0.7),
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
            color: Color(0xFF6366F1),
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
}

class BouncingWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const BouncingWidget({super.key, required this.child, this.onTap});

  @override
  State<BouncingWidget> createState() => _BouncingWidgetState();
}

class _BouncingWidgetState extends State<BouncingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(scale: _scaleAnimation, child: widget.child),
    );
  }
}
