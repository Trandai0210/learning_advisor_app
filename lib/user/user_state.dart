import 'package:edubot/user/user_model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
abstract class UserState extends Equatable{}

class LoadingUser extends UserState{

  @override
  List<Object?> get props => [];
}

class LoadedUser extends UserState{
  List<User> users;
  LoadedUser(this.users);

  @override
  List<Object?> get props => [users];
}

class LoadUserFailure extends UserState{
  String error;
  LoadUserFailure(this.error);

  @override
  List<Object?> get props => [error];
}