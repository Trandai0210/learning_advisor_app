import 'package:edubot/question/question_model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

@immutable
abstract class QuestionState extends Equatable{}

class LoadingQuestions extends QuestionState{
  
  @override
  List<Object?> get props => [];
}

class LoadedQuestions extends QuestionState{
  List<Question> questions;
  LoadedQuestions(this.questions);

  @override
  List<Object?> get props => [questions];
}

class FailureQuestion extends QuestionState{
  String error;
  FailureQuestion(this.error);
  
  @override
  List<Object?> get props => [error];
}