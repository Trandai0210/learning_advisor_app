
import 'package:edubot/answer/answer_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'add_answer_state.dart';

class AddAnswerCubit extends Cubit<AddAnswerState>{
  AddAnswerCubit(this.answerRepository):super(AddAnswerInitial());

  final AnswerRepository answerRepository;

  Future<void> addAnswer(String content) async {
    if(content.isEmpty){
      emit(AddAnswerError(error: "Câu trả lời không được để trống!"));
      return;
    }
    try {
      emit(AddingAnswer());
      bool status = await answerRepository.addAnswer(content);
      if(status == true){
        emit(AddedAnswer());
      } else{
        emit(AddAnswerError(error: "Lỗi"));
      }
    } catch (e) {
      emit(AddAnswerError(error: e.toString()));
    }
  }
}