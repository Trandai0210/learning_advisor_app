
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
abstract class PermissionEvent extends Equatable{}
class GetPermissionsEvent extends PermissionEvent{
  GetPermissionsEvent();
  
  @override
  // TODO: implement props
  List<Object?> get props => [];
}
