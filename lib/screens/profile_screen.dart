import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../core/constants/colors.dart';
import 'edit_profile_screen.dart';
import 'edit_account_screen.dart';
import 'terms_privacy_screen.dart';
import 'edit_fitness_goals_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    final name = user != null ? "${user.firstName} ${user.lastName}" : "User";
    final subtitle = "Food Blogger"; // Placeholder, can be dynamic later
    final profileImagePath = user?.profileImageUrl ?? '';
    String assetPath = '';
    if (profileImagePath.startsWith('/users/')) {
      assetPath = 'assets/images/users/' + profileImagePath.split('/').last;
    } else if (profileImagePath.startsWith('assets/')) {
      assetPath = profileImagePath;
    }
    print('Profile image asset path: $assetPath');

    Widget profileImageWidget;
    if (assetPath.isNotEmpty) {
      profileImageWidget = Image.asset(assetPath, fit: BoxFit.cover);
    } else {
      profileImageWidget = const Icon(Icons.person, size: 80, color: Colors.grey);
    }

    final options = [
      _ProfileOption(
        icon: Icons.person,
        label: 'Edit Personal Info',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EditProfileScreen()),
          );
        },
      ),
      _ProfileOption(
        icon: Icons.manage_accounts,
        label: 'Edit Account',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EditAccountScreen()),
          );
        },
      ),
      _ProfileOption(
        icon: Icons.fitness_center,
        label: 'Edit Fitness goal',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EditFitnessGoalsScreen()),
          );
        },
      ),
      _ProfileOption(
        icon: Icons.description,
        label: 'Terms & Privacy Policy',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TermsPrivacyScreen()),
          );
        },
      ),
      _ProfileOption(
        icon: Icons.logout,
        label: 'Log Out',
        onTap: () {
          // Clear user and navigate to login
          Provider.of<UserProvider>(context, listen: false).clearUser();
          Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        },
        color: Colors.red[100],
        iconColor: Colors.red,
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text('Profile', style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 18),
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipOval(child: profileImageWidget),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.pink[100],
                        shape: BoxShape.circle,
                      ),
                      child: ClipOval(child: profileImageWidget),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 15, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 0),
                itemCount: options.length,
                separatorBuilder: (context, i) => const SizedBox(height: 10),
                itemBuilder: (context, i) => options[i],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  final Color? iconColor;
  const _ProfileOption({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
    this.iconColor,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          decoration: BoxDecoration(
            color: color ?? const Color(0xFFFFF7F6),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor ?? Colors.pink, size: 24),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}