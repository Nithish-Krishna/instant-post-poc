import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.surface,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'About',
                style: GoogleFonts.inter(fontWeight: FontWeight.bold),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.background],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Icon(
                    LucideIcons.wand2,
                    color: Colors.white.withOpacity(0.2),
                    size: 80,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildDeveloperCard(),
                  const SizedBox(height: 24),
                  _buildSectionHeader("Support the Hustle"),
                  _buildSectionGroup([
                    _buildLinkTile(LucideIcons.heart, "Buy Me a Coffee", "Support independent development", null),
                    _buildLinkTile(LucideIcons.users, "Sponsor / Collaborate", "Let's build something together", null),
                  ]),
                  const SizedBox(height: 24),
                  _buildSectionHeader("Developer Credibility"),
                  _buildSectionGroup([
                    _buildLinkTile(LucideIcons.github, "GitHub Profile", "Nithish-Krishna", "https://github.com/Nithish-Krishna"),
                    _buildLinkTile(LucideIcons.layers, "Tech Stack", "Flutter Web, Firebase, Gemini AI", null),
                    _buildLinkTile(LucideIcons.code, "Open Source", "Parts of this app may become open-source.", null),
                  ]),
                  const SizedBox(height: 24),
                  _buildSectionHeader("Feedback & Growth"),
                  _buildSectionGroup([
                    _buildLinkTile(LucideIcons.bug, "Report a Bug", "Found a glitch? Let us know.", null),
                    _buildLinkTile(LucideIcons.sparkles, "Request a Feature", "What should we build next?", null),
                    _buildLinkTile(LucideIcons.messageCircle, "Give Feedback", "We love hearing from you.", null),
                  ]),
                  const SizedBox(height: 24),
                  _buildSectionHeader("How It Works"),
                  _buildSectionGroup([
                    _buildStepTile(1, "Generate", "Input your ideas and let AI do the magic."),
                    _buildStepTile(2, "Refine", "Copy the caption, music, and download the post."),
                    _buildStepTile(3, "Post", "Launch Instagram and share with the world."),
                    _buildNoteTile("Instagram restricts direct posting via web/3rd party apps to prevent spam."),
                  ]),
                  const SizedBox(height: 24),
                  _buildSectionHeader("Roadmap (Coming Soon)"),
                  _buildSectionGroup([
                    _buildLinkTile(LucideIcons.type, "AI Captions", "More variations & tones", null),
                    _buildLinkTile(LucideIcons.video, "Reel Generator", "Convert text to short videos", null),
                    _buildLinkTile(LucideIcons.hash, "Auto Hashtags", "Smart trending tags for your niche", null),
                  ]),
                  const SizedBox(height: 24),
                  _buildSectionHeader("Legal & Transparency"),
                  _buildSectionGroup([
                    _buildLinkTile(LucideIcons.shield, "Privacy Policy", "How we handle your data", null),
                    _buildLinkTile(LucideIcons.fileText, "Terms of Use", "The simple rules of our app", null),
                    _buildNoteTile("We never store your Instagram credentials."),
                  ]),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(LucideIcons.wand2, color: AppColors.primary, size: 40),
        ),
        const SizedBox(height: 16),
        Text(
          "Instant Post",
          style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white),
        ),
        const SizedBox(height: 4),
        Text(
          "v1.0.0",
          style: GoogleFonts.inter(fontSize: 14, color: Colors.white54),
        ),
        const SizedBox(height: 12),
        Text(
          "Studio-grade AI marketing for creators who hate friction.",
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(fontSize: 16, color: Colors.white70, fontStyle: FontStyle.italic),
        ),
      ],
    );
  }

  Widget _buildDeveloperCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: AppColors.primary,
                child: Icon(LucideIcons.user, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Nithish Krishna", style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white)),
                  Text("Full-stack Developer", style: GoogleFonts.inter(fontSize: 12, color: Colors.white54)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            "Every features is built with the goal of making social media creation effortless. Your feedback helps this project grow!",
            style: GoogleFonts.inter(fontSize: 14, color: Colors.white70, height: 1.5),
          ),
          const SizedBox(height: 12),
          Text(
            "Built at 2AM ☕",
            style: GoogleFonts.inter(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(
          title.toUpperCase(),
          style: GoogleFonts.inter(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.1),
        ),
      ),
    );
  }

  Widget _buildSectionGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildLinkTile(IconData icon, String title, String subtitle, String? url) {
    return ListTile(
      onTap: () async {
        if (url != null) {
          final uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) await launchUrl(uri);
        }
      },
      leading: Icon(icon, color: Colors.white70, size: 20),
      title: Text(title, style: GoogleFonts.inter(fontSize: 14, color: Colors.white)),
      subtitle: Text(subtitle, style: GoogleFonts.inter(fontSize: 12, color: Colors.white38)),
      trailing: const Icon(LucideIcons.externalLink, color: Colors.white12, size: 14),
    );
  }

  Widget _buildStepTile(int step, String title, String subtitle) {
    return ListTile(
      leading: Container(
        width: 24,
        height: 24,
        decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
        child: Center(child: Text("$step", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white))),
      ),
      title: Text(title, style: GoogleFonts.inter(fontSize: 14, color: Colors.white)),
      subtitle: Text(subtitle, style: GoogleFonts.inter(fontSize: 12, color: Colors.white38)),
    );
  }

  Widget _buildNoteTile(String note) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.02), borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16))),
      child: Row(
        children: [
          const Icon(LucideIcons.info, color: Colors.white24, size: 14),
          const SizedBox(width: 8),
          Expanded(child: Text(note, style: GoogleFonts.inter(fontSize: 11, color: Colors.white24, fontStyle: FontStyle.italic))),
        ],
      ),
    );
  }
}
