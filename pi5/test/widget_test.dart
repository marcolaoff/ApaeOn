// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pi5/main.dart';

void main() {
  testWidgets('LoginScreen mostra campos e botões', (WidgetTester tester) async {
    await tester.pumpWidget(const MainApp()); // Se o seu widget principal for MainApp

    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Registrar-se'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2)); // email e senha
  });
}

