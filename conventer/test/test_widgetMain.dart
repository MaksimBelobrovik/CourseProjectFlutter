import 'package:flutter/material.dart';
import 'package:conventer/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main(){
  testWidgets('Main widget test', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());
    var button1 = find.text("Convert To");
    expect(button1,findsOneWidget);
    var button2 = find.text("Convert From");
    expect(button2,findsOneWidget);
  });
}