// test/login_page_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc_template/data/auth/bloc/login/login_bloc.dart';
import 'package:flutter_bloc_template/page/login.dart';

void main() {
  testWidgets('LoginPage render username+password+tombol', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider(create: (_) => LoginBloc(), child: const LoginPage()),
      ),
    );
    expect(find.byKey(const Key('username')), findsOneWidget);
    expect(find.byKey(const Key('password')), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Masuk'), findsOneWidget);
  });
}
