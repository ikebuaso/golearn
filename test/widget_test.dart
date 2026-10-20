import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golearn/main.dart';

void main() {
  testWidgets('landing page explains Go Learn and offers Android download', (
    tester,
  ) async {
    await tester.pumpWidget(const GoLearnApp());

    expect(find.text('Go Learn'), findsOneWidget);
    expect(find.text('Learn something.\nBecome someone.'), findsOneWidget);
    expect(find.text('Learn at your pace'), findsOneWidget);
    expect(find.text('Put it into practice'), findsOneWidget);
    expect(find.text('See your progress'), findsOneWidget);
    expect(find.text('Get the Android app'), findsOneWidget);

    final downloadButton = find.text('Get the Android app');
    await tester.ensureVisible(downloadButton);
    await tester.tap(downloadButton);
    await tester.pump();

    expect(
      find.text('The Android download will be available here soon.'),
      findsOneWidget,
    );
  });

  testWidgets('sign-up entry opens and explains the auth setup preview', (
    tester,
  ) async {
    await tester.pumpWidget(const GoLearnApp());

    final signUpButton = find.text('Create your account');
    await tester.ensureVisible(signUpButton);
    await tester.tap(signUpButton);
    await tester.pumpAndSettle();

    expect(find.text('Start learning.'), findsOneWidget);
    expect(find.text('Your name'), findsOneWidget);
    expect(find.text('Email address'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);

    await tester.tap(find.text('Create account'));
    await tester.pump();

    expect(
      find.text('Add CLERK_PUBLISHABLE_KEY to enable sign-up.'),
      findsOneWidget,
    );
  });

  testWidgets('landing page adapts to a phone-sized viewport', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const GoLearnApp());
    await tester.pumpAndSettle();

    expect(find.text('Learn something.\nBecome someone.'), findsOneWidget);
    expect(find.text('See your progress'), findsOneWidget);
    final layoutException = tester.takeException();
    expect(layoutException, isNull, reason: layoutException.toString());
  });
}
