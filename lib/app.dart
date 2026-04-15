import 'package:flutter/material.dart';

import 'data/demo_sections.dart';
import 'screens/auth_gate_page.dart';
import 'services/auth_session_store.dart';
import 'services/device_authenticator.dart';
import 'theme/app_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    DeviceAuthenticator? authenticator,
    AuthSessionStore? sessionStore,
  }) : _authenticator = authenticator ?? const LocalDeviceAuthenticator(),
       _sessionStore = sessionStore ?? const SharedPrefsAuthSessionStore();

  final DeviceAuthenticator _authenticator;
  final AuthSessionStore _sessionStore;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Details',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: AuthGatePage(
        authenticator: _authenticator,
        sessionStore: _sessionStore,
        sections: demoSections,
      ),
    );
  }
}
