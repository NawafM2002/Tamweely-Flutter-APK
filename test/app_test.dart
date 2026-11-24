import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tamweely/main.dart';
import 'package:tamweely/model.dart';
import 'package:latlong2/latlong.dart';
void main() {
  test('Submission snapshots request and clears draft', () {
    final s = DemoState();
    s.setValue('project.name', 'مشروع تجريبي');
    s.setValue('financial.amount', '1000');
    s.setValue('financial.currency', 'ريال يمني');
    s.location = const LatLng(15.3, 44.2);
    final r = s.submit();
    expect(r.id, 'TW-0001');
    expect(r.project, 'مشروع تجريبي');
    expect(s.requests.length, 1);
    expect(s.data, isEmpty);
    expect(s.location, isNull);
    expect(s.unread, 2);
  });
  testWidgets('Demo login and applicant dashboard navigation', (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(TamweelyApp());
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('project-background-artwork')), findsOneWidget);
    final demo = find.text('الدخول بحساب تجريبي');
    await tester.ensureVisible(demo);
    await tester.tap(demo);
    await tester.pumpAndSettle();
    expect(find.text('تمويلي | لوحة التحكم'), findsOneWidget);
    expect(find.byKey(const ValueKey('project-background-artwork')), findsOneWidget);
    expect(Directionality.of(tester.element(find.text('تمويلي | لوحة التحكم'))), TextDirection.rtl);
    await tester.tap(find.text('إنشاء طلب تمويل'));
    await tester.pumpAndSettle();
    expect(find.text('بيانات المشروع'), findsWidgets);
  });
}
