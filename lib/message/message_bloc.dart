import 'package:edubot/message/message_event.dart';
import 'package:edubot/message/message_repository.dart';
import 'package:edubot/message/message_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MessageBloc extends Bloc<MessageEvent, MessageState>{
  final MessageRepository _messageRepository;
  MessageBloc(this._messageRepository): super(LoadingMessages()){
    on<GetMessagesEvent>((event, emit) async {
      try {
        emit(LoadingMessages());
        var data = await _messageRepository.getMessages(); 
        emit(LoadedMessages(data));
      } catch (e) {
        emit(LoadMessagesFailure(e.toString()));
      }
    });
  }
}