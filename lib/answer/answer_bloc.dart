import 'package:edubot/answer/answer_repository.dart';
import 'package:edubot/answer/answer_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'answer_event.dart';

class AnswerBloc extends Bloc<AnswerEvent, AnswerState>{
  final AnswerRepository _answerRepository;

  AnswerBloc(this._answerRepository) : super(AnswerLoadingState()) {
    on<loadAnswerEvent>((event, emit) async {
      emit(AnswerLoadingState());
      try {
        final answers = await _answerRepository.getAnswers();
        emit(AnswerLoadedState(answers));
      } catch (e) {
        emit(AnswerErrorState(e.toString()));
      }
    });
  }
}