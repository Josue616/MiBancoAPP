import 'package:flutter_test/flutter_test.dart';

import 'package:mibancoemprendedor/main.dart';

void main() {
  testWidgets('MiApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(MiApp());
  });
}
