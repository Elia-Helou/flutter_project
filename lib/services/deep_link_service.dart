import 'package:app_links/app_links.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DeepLinkService {
  StreamSubscription? _sub;
  final BuildContext context;
  final AppLinks _appLinks = AppLinks();

  DeepLinkService(this.context) {
    _initDeepLinks();
  }

  void _initDeepLinks() {
    _sub = _appLinks.uriLinkStream.listen((Uri? uri) {
      _handleDeepLink(uri);
    }, onError: (err) {
      print('Deep link error: $err');
    });
  }

  Future<void> _handleDeepLink(Uri? uri) async {
    if (uri == null) return;

    if (uri.scheme == 'healthapp' && uri.host == 'reset-password') {
      final token = uri.queryParameters['token'];
      if (token != null) {
        // Verify token with backend
        try {
          final response = await http.post(
            Uri.parse('http://10.0.2.2:5000/auth/verify-token'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'token': token}),
          );

          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            if (data['valid'] == true) {
              // Navigate to reset password screen
              if (context.mounted) {
                Navigator.pushNamed(
                  context,
                  '/reset-password',
                  arguments: {
                    'token': token,
                    'email': data['email'],
                  },
                );
              }
            } else {
              _showError('Invalid or expired reset link');
            }
          } else {
            _showError('Failed to verify reset link');
          }
        } catch (e) {
          _showError('Error verifying reset link');
        }
      }
    }
  }

  void _showError(String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  void dispose() {
    _sub?.cancel();
  }
} 