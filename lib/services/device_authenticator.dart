import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';

enum AuthState { authenticating, success, failed, unavailable }

class AuthResult {
  const AuthResult({required this.state, required this.message});

  final AuthState state;
  final String message;
}

abstract class DeviceAuthenticator {
  const DeviceAuthenticator();

  Future<AuthResult> authenticate();
}

class LocalDeviceAuthenticator extends DeviceAuthenticator {
  const LocalDeviceAuthenticator();

  @override
  Future<AuthResult> authenticate() async {
    if (kIsWeb || 
        defaultTargetPlatform == TargetPlatform.macOS || 
        defaultTargetPlatform == TargetPlatform.windows || 
        defaultTargetPlatform == TargetPlatform.linux) {
      return const AuthResult(
        state: AuthState.success,
        message: 'auth skipped on desktop/web',
      );
    }

    final localAuthentication = LocalAuthentication();
    final isSupported = await localAuthentication.isDeviceSupported();
    final canCheckBiometrics = await localAuthentication.canCheckBiometrics;

    if (!isSupported && !canCheckBiometrics) {
      return const AuthResult(
        state: AuthState.unavailable,
        message: 'Authentication is not available on this device',
      );
    }

    try {
      final authenticated = await localAuthentication.authenticate(
        localizedReason: 'Unlock to continue',
        biometricOnly: false,
        persistAcrossBackgrounding: true,
      );

      if (authenticated) {
        return const AuthResult(
          state: AuthState.success,
          message: 'auth success',
        );
      }

      return const AuthResult(
        state: AuthState.failed,
        message: 'Authentication failed',
      );
    } on LocalAuthException {
      return const AuthResult(
        state: AuthState.failed,
        message: 'Authentication failed',
      );
    } on PlatformException {
      return const AuthResult(
        state: AuthState.failed,
        message: 'Authentication failed',
      );
    }
  }
}
