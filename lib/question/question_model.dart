class Question{
  final int questionId;
  late final String keyword;
  final int answerId;
  final String answerContent;

  Question({
    required this.questionId,
    required this.keyword,
    required this.answerId,
    required this.answerContent
  });

  factory Question.fromJson(Map<String , dynamic> json){
    return Question(questionId: json['questionId'], keyword: json['keyword'], answerId: json['answerId'],answerContent: json['answerContent']);
  }
}