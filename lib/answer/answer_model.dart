class Answer{
  final int answerId;
  final String content;

  Answer({
    required this.answerId,
    required this.content,
  });

  factory Answer.fromJson(Map<String, dynamic> json){
    return Answer(answerId: json['answerId'], content: json['content']);
  }
}