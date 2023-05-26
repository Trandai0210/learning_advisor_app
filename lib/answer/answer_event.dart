import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

@immutable
abstract class AnswerEvent extends Equatable{
  const AnswerEvent();
}

class loadAnswerEvent extends AnswerEvent{
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class addAnswerEvent extends AnswerEvent{
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class updateAnswerEvent extends AnswerEvent{
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class deleteAnswerEvent extends AnswerEvent{
  @override
  // TODO: implement props
  List<Object?> get props => [];
}