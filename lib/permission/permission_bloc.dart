import 'package:edubot/permission/permission_event.dart';
import 'package:edubot/permission/permission_state.dart';
import 'package:edubot/permission/permisson_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PermissionBloc extends Bloc<PermissionEvent, PermissionState>{
  final PermissionRepository _permissionRepository;

  PermissionBloc(this._permissionRepository) : super(LoadingPermission()){
    on<GetPermissionsEvent>((event, emit) async {
      try {
        emit(LoadingPermission());
        var data = await _permissionRepository.getPermissions();
        emit(LoadedPermission(data)); 
      } catch (e) {
        emit(FailurePermission(e.toString()));
      }
    });
  }
}