import 'package:flutter/material.dart';

class TermsPrivacyScreen extends StatelessWidget {
  const TermsPrivacyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Terms & Privacy'),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Terms of Service'),
              Tab(text: 'Privacy Policy'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _TermsOfServiceTab(),
            _PrivacyPolicyTab(),
          ],
        ),
      ),
    );
  }
}

class _TermsOfServiceTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Terms of Service',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          _buildSection(
            'Acceptance of Terms',
            'By accessing and using this application, you accept and agree to be bound by the terms and provision of this agreement.',
          ),
          _buildSection(
            'Use License',
            'Permission is granted to temporarily download one copy of the app for personal, non-commercial transitory viewing only.',
          ),
          _buildSection(
            'User Account',
            'You are responsible for maintaining the confidentiality of your account and password. You agree to accept responsibility for all activities that occur under your account.',
          ),
          _buildSection(
            'Service Modifications',
            'We reserve the right to modify or discontinue, temporarily or permanently, the service with or without notice.',
          ),
          _buildSection(
            'Content',
            'Our service allows you to post, link, store, share and otherwise make available certain information, text, graphics, or other material.',
          ),
          _buildSection(
            'Termination',
            'We may terminate or suspend your account and bar access to the Service immediately, without prior notice or liability.',
          ),
          _buildSection(
            'Governing Law',
            'These Terms shall be governed and construed in accordance with the laws, without regard to its conflict of law provisions.',
          ),
        ],
      ),
    );
  }
}

class _PrivacyPolicyTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Privacy Policy',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          _buildSection(
            'Information Collection',
            'We collect information that you provide directly to us when you create an account, including your name, email address, and other profile information.',
          ),
          _buildSection(
            'How We Use Your Information',
            'We use the information we collect to provide, maintain, and improve our services, communicate with you, and protect our services and users.',
          ),
          _buildSection(
            'Information Sharing',
            'We do not share your personal information with companies, organizations, or individuals outside of our service except in the following cases:\n'
            '• With your consent\n'
            '• For legal reasons\n'
            '• To protect rights and safety',
          ),
          _buildSection(
            'Data Security',
            'We work hard to protect our users from unauthorized access to or unauthorized alteration, disclosure, or destruction of information we hold.',
          ),
          _buildSection(
            'Your Rights',
            'You have the right to:\n'
            '• Access your personal data\n'
            '• Correct inaccurate data\n'
            '• Request deletion of your data\n'
            '• Object to our use of your data',
          ),
          _buildSection(
            'Changes to This Policy',
            'We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page.',
          ),
          _buildSection(
            'Contact Us',
            'If you have any questions about this Privacy Policy, please contact us.',
          ),
        ],
      ),
    );
  }
}

Widget _buildSection(String title, String content) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 8),
      Text(
        content,
        style: const TextStyle(
          fontSize: 16,
          height: 1.5,
        ),
      ),
      const SizedBox(height: 24),
    ],
  );
} 