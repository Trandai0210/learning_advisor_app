import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
abstract class MessageEvent extends Equatable{
  const MessageEvent();
}

class GetMessagesEvent extends MessageEvent{
  @override
  List<Object?> get props => [];
}