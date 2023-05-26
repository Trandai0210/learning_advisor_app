import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
abstract class UserEvent extends Equatable{
  const UserEvent();
}
class GetUsersEvent extends UserEvent{
  @override
  List<Object?> get props => [];
}