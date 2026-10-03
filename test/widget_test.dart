import 'package:flutter_test/flutter_test.dart';
import 'package:hyper_net/application.dart';

void main() {
  testWidgets('App builds', (WidgetTester tester) async {
    await tester.pumpWidget(const Application());
    expect(find.text('HyperNet'), findsOneWidget);
  });
}
