import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

@immutable
abstract class QuestionEvent extends Equatable{}
class GetQuestionsEvent extends QuestionEvent{
  int page;
  int size;
  String? search;
  
  GetQuestionsEvent({required this.page, required this.size, required this.search});
  
  @override
  // TODO: implement props
  List<Object?> get props => [page,size,search];
}