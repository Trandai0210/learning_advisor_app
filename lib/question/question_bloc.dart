import 'package:edubot/question/question_event.dart';
import 'package:edubot/question/question_repository.dart';
import 'package:edubot/question/question_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class QuestionBloc extends Bloc<QuestionEvent, QuestionState>{
  final QuestionRepository _repository;
  QuestionBloc(this._repository): super(LoadingQuestions()){
    on<GetQuestionsEvent>((event, emit) async {
      try {
        emit(LoadingQuestions());
        var data = await _repository.getQuestions(0, 5, "");
        emit(LoadedQuestions(data)); 
      } catch (e) {
        emit(FailureQuestion(e.toString()));
      }
    });
  }
  
}