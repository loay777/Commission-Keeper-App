// To parse this JSON data, do
//
//     final commission = commissionFromJson(jsonString);

import 'dart:convert';

Commission commissionFromJson(String str) {
  final jsonData = json.decode(str);
  return Commission.fromMap(jsonData);
}

String commissionToJson(Commission data) {
  final dyn = data.toMap();
  return json.encode(dyn);
}

class Commission {
  int id;
  String commissionTitle;
  String commissionValue;
  String date;

  Commission({
    this.id,
    this.commissionTitle,
    this.commissionValue,
    this.date,
  });

  factory Commission.fromMap(Map<String, dynamic> json) => new Commission(
    id: json["id"],
    commissionTitle: json["commission_title"],
    commissionValue: json["commission_value"],
    date: json["date"],
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "commission_title": commissionTitle,
    "commission_value": commissionValue,
    "date": date,
  };
}
