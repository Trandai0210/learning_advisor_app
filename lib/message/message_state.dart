import 'package:edubot/message/message_model.dart';
import 'package:equatable/equatable.dart';

abstract class MessageState extends Equatable{}

class LoadingMessages extends MessageState{

  @override
  List<Object?> get props => [];
}

class LoadedMessages extends MessageState{
  List<Message> messages;
  LoadedMessages(this.messages);

  @override
  List<Object?> get props => [messages];
}

class LoadMessagesFailure extends MessageState{
  String error;
  LoadMessagesFailure(this.error);
  
  @override
  List<Object?> get props => [error];

}