class Message{
  final int messageId;
  final String content;
  final String createdAt;
  final int userId;
  final String userName;
  final String gmail;
  final String userImage;
  final int facultyId;
  final String facultyName;
  Message({
    required this.messageId,
    required this.content,
    required this.createdAt,
    required this.userId,
    required this.userName,
    required this.gmail,
    required this.userImage,
    required this.facultyId,
    required this.facultyName
  });

  factory Message.fromJson(Map<String,dynamic> json){
    return Message(
      messageId: json['messageId'], 
      content: json['content'], 
      createdAt: json['createdAt'], 
      userId: json['userId'], 
      userName: json['userName'], 
      gmail: json['gmail'], 
      userImage: json['userImage'], 
      facultyId: json['facultyId'], 
      facultyName: json['facultyName']
    );
  }
}