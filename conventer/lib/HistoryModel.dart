import 'dart:convert';

HistoryModel historyFromJson(String str) {
  final jsonData = json.decode(str);
  return HistoryModel.fromMap(jsonData);
}

String historyToJson(HistoryModel data) {
  final dyn = data.toMap();
  return json.encode(dyn);
}

class HistoryModel {
  int id;
  String firstName;
  String firstVal;
  String lastName;
  String secondVal;

  HistoryModel({
    this.id,
    this.firstName,
    this.firstVal,
    this.lastName,
    this.secondVal,
  });

  factory HistoryModel.fromMap(Map<String, dynamic> json) => new HistoryModel(
    id: json["id"],
    firstName: json["first_name"],
    firstVal: json["first_val"],
    lastName: json["last_name"],
    secondVal: json["second_val"],
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "first_name": firstName,
    "first_val": firstVal,
    "last_name": lastName,
    "seccond_val": secondVal,
  };
}