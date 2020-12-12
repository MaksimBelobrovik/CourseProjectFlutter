import 'package:flutter_test/flutter_test.dart';
import 'package:conventer/main.dart';
void main(){
  test("ConvertToTest", (){
    double initValue=10.0;
    double initCourse=5.0;
    double res=ConvertTo(initValue,initCourse);
    expect(res, 2.0);
  });
}