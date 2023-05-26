import 'package:edubot/user/user_event.dart';
import 'package:edubot/user/user_repository.dart';
import 'package:edubot/user/user_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserBloc extends Bloc<UserEvent,UserState>{
  final UserRepository _userRepository;
  UserBloc(this._userRepository):super(LoadingUser()){
    on<GetUsersEvent>((event, emit) async {
      try {
        emit(LoadingUser());
        var data = await _userRepository.getUser();
        emit(LoadedUser(data));
      } catch (e) {
        emit(LoadUserFailure(e.toString()));
      }
    });
  }
}