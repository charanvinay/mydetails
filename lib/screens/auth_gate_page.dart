import 'package:flutter/material.dart';

import '../models/detail_models.dart';
import '../services/auth_session_store.dart';
import '../services/device_authenticator.dart';
import '../widgets/gradient_icon_badge.dart';
import 'home_page.dart';

class AuthGatePage extends StatefulWidget {
  const AuthGatePage({
    super.key,
    required this.authenticator,
    required this.sessionStore,
    required this.sections,
  });

  final DeviceAuthenticator authenticator;
  final AuthSessionStore sessionStore;
  final List<DetailSection> sections;

  @override
  State<AuthGatePage> createState() => _AuthGatePageState();
}

class _AuthGatePageState extends State<AuthGatePage> {
  AuthState _authState = AuthState.authenticating;
  String _message = 'Authenticating';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkSessionOrAuthenticate();
    });
  }

  Future<void> _checkSessionOrAuthenticate() async {
    final hasValidSession = await widget.sessionStore.hasValidSession();
    if (!mounted) {
      return;
    }

    if (hasValidSession) {
      _openHome();
      return;
    }

    await _authenticate();
  }

  Future<void> _authenticate() async {
    if (!mounted) {
      return;
    }

    setState(() {
      _authState = AuthState.authenticating;
      _message = 'Authenticating';
    });

    final result = await widget.authenticator.authenticate();
    if (!mounted) {
      return;
    }

    if (result.state == AuthState.success) {
      await widget.sessionStore.saveSuccessfulAuth();
      if (!mounted) {
        return;
      }
      _openHome();
      return;
    }

    setState(() {
      _authState = result.state;
      _message = result.message;
    });
  }

  void _openHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => HomePage(sections: widget.sections),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAuthenticating = _authState == AuthState.authenticating;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420),
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: theme.dividerColor.withValues(alpha: 0.8),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GradientIconBadge(
                    icon: Icons.lock_open_rounded,
                    size: 84,
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.tertiary,
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _message,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'The device prompt can use biometrics, PIN, pattern, or passcode based on what the phone supports.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  if (isAuthenticating) const CircularProgressIndicator(),
                  if (!isAuthenticating)
                    ElevatedButton(
                      onPressed: _authenticate,
                      child: const Text('Try again'),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
