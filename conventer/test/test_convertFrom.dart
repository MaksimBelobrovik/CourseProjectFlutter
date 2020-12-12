import 'package:flutter_test/flutter_test.dart';
import 'package:conventer/main.dart';
void main(){
  test("ConvertFromTest", (){
    double initValue=10.0;
    double initCourse=5.0;
    double res=ConvertFrom(initValue,initCourse);
    expect(res, 50.0);
  });
}