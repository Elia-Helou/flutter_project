import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/auth_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false).user;
    _firstNameController = TextEditingController(text: user?.firstName ?? '');
    _lastNameController = TextEditingController(text: user?.lastName ?? '');
    _phoneController = TextEditingController(text: user?.phoneNumber?.toString() ?? '');
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _savePersonalInfo() async {
    if (_formKey.currentState?.validate() ?? false) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = userProvider.user;
      
      if (user != null) {
        try {
          // Update in database
          await authService.updateProfile(
            email: user.email,
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            phone_number: _phoneController.text.trim()
          );

          // Update UI
          final updatedUser = user.copyWith(
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            phoneNumber: _phoneController.text.trim(),
          );
          userProvider.setUser(updatedUser);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile updated successfully')),
            );
            Navigator.pop(context);
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to update profile: ${e.toString()}')),
            );
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    String assetPath = '';
    if (user?.profileImageUrl != null && user!.profileImageUrl!.startsWith('/users/')) {
      assetPath = 'assets/images/users/' + user.profileImageUrl!.split('/').last;
    } else if (user?.profileImageUrl != null && user!.profileImageUrl!.startsWith('assets/')) {
      assetPath = user.profileImageUrl!;
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
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
                      child: ClipOval(
                        child: assetPath.isNotEmpty
                            ? Image.asset(assetPath, fit: BoxFit.cover)
                            : const Icon(Icons.person, size: 60, color: Colors.grey),
                      ),
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
                        child: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  labelText: 'First Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Enter first name' : null,
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Last Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Enter last name' : null,
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) => value == null || value.isEmpty ? 'Enter phone number' : (int.tryParse(value) == null ? 'Phone number must be digits only' : null),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _savePersonalInfo,
                      child: const Text('Save'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 