part of 'add_answer_cubit.dart';

@immutable
abstract class AddAnswerState{}

class AddAnswerInitial extends AddAnswerState{}
class AddAnswerError extends AddAnswerState{
  final String error;
  AddAnswerError({required this.error});
}

class AddingAnswer extends AddAnswerState{}

class AddedAnswer extends AddAnswerState{}