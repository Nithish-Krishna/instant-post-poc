import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../../../core/config/app_environment.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../auth/user_service.dart';

class CreditTopBar extends StatelessWidget {
  const CreditTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final environment = context.watch<AppEnvironment>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Demo / Production Switch
          Row(
            children: [
              Text(
                "Prod",
                style: GoogleFonts.inter(
                  color: !environment.isDemoMode
                      ? Colors.white
                      : Colors.white.withOpacity(0.5),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Switch(
                value: environment.isDemoMode,
                onChanged: (bool value) {
                  if (value) {
                    // Switching TO Demo Mode is instant
                    environment.toggleMode(true);
                  } else {
                    // Switching TO Prod Mode (value is false) requires password
                    _showPasswordDialog(context, environment);
                  }
                },
                activeColor: AppColors.primary,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: Colors.grey.withOpacity(0.3),
              ),
              Text(
                "Demo",
                style: GoogleFonts.inter(
                  color: environment.isDemoMode
                      ? Colors.white
                      : Colors.white.withOpacity(0.5),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          // Credit Display
          StreamBuilder<int>(
            stream: FirebaseAuth.instance.currentUser != null
                ? UserService().getUserCredits(FirebaseAuth.instance.currentUser!.uid)
                : Stream.value(0),
            builder: (context, snapshot) {
              final aiCredits = snapshot.data ?? 0;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.zap, color: AppColors.warning, size: 16),
                    const SizedBox(width: 8),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) => SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, -0.5),
                          end: Offset.zero,
                        ).animate(animation),
                        child: FadeTransition(opacity: animation, child: child),
                      ),
                      child: Text(
                        "$aiCredits",
                        key: ValueKey<int>(aiCredits),
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
          ),
        ],
      ),
    );
  }

  void _showPasswordDialog(BuildContext context, AppEnvironment environment) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          "Enter Admin Code",
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: controller,
          obscureText: true,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Password",
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.primary),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (controller.text == 'Nieit@123') {
                environment.toggleMode(false);
              }
              Navigator.pop(context);
            },
            child: Text(
              "Submit",
              style: GoogleFonts.inter(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
