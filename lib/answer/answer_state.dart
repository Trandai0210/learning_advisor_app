
import 'package:edubot/answer/answer_model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
abstract class AnswerState extends Equatable{}

//data loading state
class AnswerLoadingState extends AnswerState{

  @override
  List<Object?> get props => [];
}

//data loaded state
class AnswerLoadedState extends AnswerState{
  AnswerLoadedState(this.answers);
  final List<Answer> answers;

  @override
  List<Object?> get props => [answers];

}

class AnswerAddingState extends AnswerState{
  @override
  List<Object?> get props => [];
}

class AnswerAddedState extends AnswerState{
  AnswerAddedState(this.status);
  final bool status;
  @override
  List<Object?> get props => [status];
}

class AnswerUpdatingState extends AnswerState{
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class AnswerUpdatedState extends AnswerState{
  AnswerUpdatedState(this.status);
  final bool status;
  @override
  List<Object?> get props => [status];
}

class AnswerDeletingState extends AnswerState{
  @override
  List<Object?> get props => [];
}

class AnswerDeletedState extends AnswerState{
  AnswerDeletedState(this.status);
  final bool status;
  @override
  List<Object?> get props => [status];
}
//data error loading state
class AnswerErrorState extends AnswerState{
  AnswerErrorState(this.error);
  final String error;

  @override
  List<Object?> get props => [error];
}
