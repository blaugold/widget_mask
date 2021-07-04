import 'package:flutter_test/flutter_test.dart';
import 'package:widget_mask_example/main.dart';

void main() {
  testWidgets('smoke test', (tester) async {
    await tester.pumpWidget(const App());
  });
}
