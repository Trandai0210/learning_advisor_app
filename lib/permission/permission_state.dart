import 'package:edubot/permission/perrmisson_model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

@immutable
abstract class PermissionState extends Equatable{}

class LoadingPermission extends PermissionState{
  @override
  List<Object?> get props => [];
}

class LoadedPermission extends PermissionState{
  List<Permission> permissions;
  LoadedPermission(this.permissions);
  @override
  List<Object?> get props => [permissions];
}

class FailurePermission extends PermissionState{
  String error;
  FailurePermission(this.error);

  @override
  List<Object?> get props => [error];
  
}