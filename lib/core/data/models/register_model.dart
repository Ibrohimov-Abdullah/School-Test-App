// To parse this JSON data, do
//
//     final registerModel = registerModelFromJson(jsonString);

import 'dart:convert';

RegisterModel registerModelFromJson(String str) => RegisterModel.fromJson(json.decode(str));

String registerModelToJson(RegisterModel data) => json.encode(data.toJson());

class RegisterModel {
  final String? access;
  final String? refresh;
  final User? user;

  RegisterModel({
    this.access,
    this.refresh,
    this.user,
  });

  RegisterModel copyWith({
    String? access,
    String? refresh,
    User? user,
  }) =>
      RegisterModel(
        access: access ?? this.access,
        refresh: refresh ?? this.refresh,
        user: user ?? this.user,
      );

  factory RegisterModel.fromJson(Map<String, dynamic> json) => RegisterModel(
    access: json["access"],
    refresh: json["refresh"],
    user: json["user"] == null ? null : User.fromJson(json["user"]),
  );

  Map<String, dynamic> toJson() => {
    "access": access,
    "refresh": refresh,
    "user": user?.toJson(),
  };
}

class User {
  final int? pk;
  final String? email;

  User({
    this.pk,
    this.email,
  });

  User copyWith({
    int? pk,   String? email,
  }) =>
      User(
        pk: pk ?? this.pk,
        email: email ?? this.email,
      );

  factory User.fromJson(Map<String, dynamic> json) => User(
    pk: json["pk"],
    email: json["email"],
  );

  Map<String, dynamic> toJson() => {
    "pk": pk,
    "email": email,
  };
}
