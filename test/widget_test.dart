import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mydetails/app.dart';
import 'package:mydetails/services/auth_session_store.dart';
import 'package:mydetails/services/device_authenticator.dart';

class PendingAuthenticator extends DeviceAuthenticator {
  const PendingAuthenticator();

  @override
  Future<AuthResult> authenticate() => Completer<AuthResult>().future;
}

class SuccessAuthenticator extends DeviceAuthenticator {
  const SuccessAuthenticator();

  @override
  Future<AuthResult> authenticate() async {
    return const AuthResult(state: AuthState.success, message: 'auth success');
  }
}

class FakeAuthSessionStore extends AuthSessionStore {
  FakeAuthSessionStore({this.hasSession = false});

  bool hasSession;
  int savedCount = 0;

  @override
  Future<void> clear() async {
    hasSession = false;
  }

  @override
  Future<bool> hasValidSession() async => hasSession;

  @override
  Future<void> saveSuccessfulAuth() async {
    hasSession = true;
    savedCount += 1;
  }
}

void main() {
  testWidgets('shows authenticating state on launch', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MyApp(
        authenticator: const PendingAuthenticator(),
        sessionStore: FakeAuthSessionStore(),
      ),
    );

    expect(find.text('Authenticating'), findsOneWidget);
    expect(find.text('Passwords'), findsNothing);
  });

  testWidgets('shows home sections after successful auth', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MyApp(
        authenticator: const SuccessAuthenticator(),
        sessionStore: FakeAuthSessionStore(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('My Details'), findsOneWidget);
    expect(find.text('Passwords'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Cards'), 200);
    await tester.pumpAndSettle();
    expect(find.text('Cards'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Addresses'), 300);
    await tester.pumpAndSettle();
    expect(find.text('Addresses'), findsOneWidget);
  });

  testWidgets('opens detail screen from section show more', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MyApp(
        authenticator: const SuccessAuthenticator(),
        sessionStore: FakeAuthSessionStore(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Show more').first);
    await tester.pumpAndSettle();

    expect(find.text('Passwords'), findsWidgets);
    expect(find.text('Google'), findsOneWidget);
    expect(find.text('Amazon'), findsOneWidget);
  });

  testWidgets('opens profile tab and shows export import actions', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MyApp(
        authenticator: const SuccessAuthenticator(),
        sessionStore: FakeAuthSessionStore(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Profile'));
    await tester.pumpAndSettle();

    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Export database'), findsOneWidget);
    expect(find.text('Import database'), findsOneWidget);
  });

  testWidgets('plus button opens add chooser', (WidgetTester tester) async {
    await tester.pumpWidget(
      MyApp(
        authenticator: const SuccessAuthenticator(),
        sessionStore: FakeAuthSessionStore(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();

    expect(find.text('What do you want to add?'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Card'), findsOneWidget);
    expect(find.text('Address'), findsOneWidget);
  });

  testWidgets('tapping item opens edit page', (WidgetTester tester) async {
    await tester.pumpWidget(
      MyApp(
        authenticator: const SuccessAuthenticator(),
        sessionStore: FakeAuthSessionStore(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Google'));
    await tester.pumpAndSettle();

    expect(find.text('Edit Passwords'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Update'), findsOneWidget);
    expect(find.byIcon(Icons.delete_outline_rounded), findsOneWidget);
  });

  testWidgets('skips device auth when cached session is still valid', (
    WidgetTester tester,
  ) async {
    final sessionStore = FakeAuthSessionStore(hasSession: true);

    await tester.pumpWidget(
      MyApp(
        authenticator: const PendingAuthenticator(),
        sessionStore: sessionStore,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('My Details'), findsOneWidget);
    expect(find.text('Authenticating'), findsNothing);
  });

  testWidgets('persists a session after successful authentication', (
    WidgetTester tester,
  ) async {
    final sessionStore = FakeAuthSessionStore();

    await tester.pumpWidget(
      MyApp(
        authenticator: const SuccessAuthenticator(),
        sessionStore: sessionStore,
      ),
    );
    await tester.pumpAndSettle();

    expect(sessionStore.savedCount, 1);
  });
}
