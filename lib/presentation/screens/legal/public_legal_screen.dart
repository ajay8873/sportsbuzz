import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';

enum LegalDocType {
  privacy,
  terms,
}

class PublicLegalScreen extends StatelessWidget {
  final LegalDocType docType;

  const PublicLegalScreen({
    super.key,
    required this.docType,
  });

  @override
  Widget build(BuildContext context) {
    final isPrivacy = docType == LegalDocType.privacy;
    final title = isPrivacy ? 'Privacy Policy' : 'Terms of Service';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/login');
            }
          },
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/icons/app_icon.png',
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Zest',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Effective Date: September 7, 2026',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
                const Divider(height: 32),

                if (isPrivacy) ..._buildPrivacyContent() else ..._buildTermsContent(),

                const Divider(height: 48),
                Center(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(LucideIcons.logIn, size: 16),
                    label: const Text('Return to Login'),
                    onPressed: () => context.go('/login'),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPrivacyContent() {
    return [
      _buildSection(
        'Overview',
        'Welcome to Zest ("we", "our", or "the App"), developed and operated by Ajay Mehta. '
        'Zest provides live tournament scoring, campus sports fest management, fixtures, and points table tracking. '
        'We respect your privacy and are committed to protecting the personal information you share with us.',
      ),
      _buildSection(
        '1. Information We Collect',
        '• Account Credentials & Profile Info: When you register via email and password, we collect your name and email address. '
        'When you sign in using Google Sign-In, we receive your basic Google profile information (name, email address, profile avatar URL) as authorized by you.\n\n'
        '• Tournament and Event Data: Information you create or manage in the App, including tournament names, dates, venues, sport categories, team rosters, fixture schedules, and live scorecards.\n\n'
        '• Device and App Usage Data: Technical logs such as connection timestamps, anonymous crash logs, and local device preferences stored on your device via secure SharedPreferences.',
      ),
      _buildSection(
        '2. How We Use Your Information',
        '• To authenticate your identity and provide secure access to your account.\n'
        '• To verify tournament organizer authority (distinguishing tournament creators, co-admins, and spectators).\n'
        '• To personalize your home feed with tournaments you host, manage, or bookmark.\n'
        '• To synchronize real-time scores, points tables, and match statistics across participants and spectators.\n'
        '• To maintain security, prevent unauthorized fixture tampering, and diagnose errors.',
      ),
      _buildHighlightBox(
        'Google User Data Limited Use Disclosure:\n'
        'Zest\'s use and transfer to any other app of information received from Google APIs adheres to the Google API Services User Data Policy, '
        'including the Limited Use requirements. We never sell your Google user data, share it with advertising networks, or use it for profiling or marketing.',
      ),
      _buildSection(
        '3. Third-Party Services',
        '• Google Identity Services: Facilitates secure, one-tap Google Sign-In authentication.\n'
        '• Supabase: Provides backend authentication, managed PostgreSQL database storage, and real-time WebSocket replication under strict security controls and data encryption.',
      ),
      _buildSection(
        '4. Data Retention and Account Deletion',
        'We retain your personal information only for as long as your account remains active or as needed to provide our services. '
        'You have the right to request deletion of your account and all associated personal data at any time.\n\n'
        'To request account deletion or data removal, please email us at mehtaajay8873@gmail.com with the subject line "Data Deletion Request". '
        'We review and process each request as early as possible. Depending on administrative review and processing queues, processing may take from a few days to a few months. '
        'If your request remains unheard or unaddressed, please feel free to submit your request again.',
      ),
      _buildSection(
        '5. Contact Information',
        'Developer: Ajay Mehta\n'
        'Email: mehtaajay8873@gmail.com\n'
        'Application: Zest (SportsBuzz)',
      ),
    ];
  }

  List<Widget> _buildTermsContent() {
    return [
      _buildSection(
        'Agreement to Terms',
        'Please read these Terms of Service ("Terms", "Agreement") carefully before using the Zest application ("the App", "Service"), operated by Ajay Mehta.\n\n'
        'By creating an account, signing in, or using Zest in any capacity, you agree to be bound by these Terms. '
        'If you disagree with any part of the terms, you may not access or use the application.',
      ),
      _buildSection(
        '1. Description of Service',
        'Zest provides live tournament management, real-time sports scoring, fixtures, squad registration, and points table administration. '
        'Services are provided on an "as is" and "as available" basis for college sports fests, club tournaments, and recreational sports events.',
      ),
      _buildSection(
        '2. User Accounts & Security',
        '• You must provide accurate and complete information when registering via email or Google Sign-In.\n'
        '• You are responsible for maintaining the confidentiality of your account credentials and for all activities that occur under your account.\n'
        '• You agree to notify us immediately of any unauthorized access to or use of your account.',
      ),
      _buildSection(
        '3. User Roles & Conduct',
        '• Tournament Organizers & Admins: Organizers are responsible for the accuracy of tournament information, fixture dates, team rosters, and fair entry of live match scores. Unauthorized tampering or fraudulent score recording is strictly prohibited.\n\n'
        '• Spectators: Users may view live scores and share public tournament codes in good faith without attempting to disrupt live streams or server operations.',
      ),
      _buildSection(
        '4. Account Deletion & Termination',
        'You may request deletion of your account at any time by emailing mehtaajay8873@gmail.com. '
        'We review and process each request as early as possible (from a few days to a few months). If your request remains unheard, you may submit it again.',
      ),
      _buildSection(
        '5. Contact Information',
        'Developer: Ajay Mehta\n'
        'Email: mehtaajay8873@gmail.com\n'
        'Application: Zest (SportsBuzz)',
      ),
    ];
  }

  Widget _buildSection(String heading, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            heading,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(
              fontSize: 13.5,
              height: 1.6,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightBox(String text) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryDark,
          height: 1.5,
        ),
      ),
    );
  }
}
