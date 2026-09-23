// test/app_shell_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc_template/main.dart';

void main() {
  testWidgets('MyApp tampilkan SplashScreen saat start', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MyApp());
    await tester.pump();
    expect(find.text('Template'), findsOneWidget);
  });
}
