class Faculty{
  final int facultyId;
  final String name;

  Faculty({
    required this.facultyId,
    required this.name
  });

  factory Faculty.fromJson(Map<String , dynamic> json){
    return Faculty(facultyId: json['facultyId'], name: json['name']);
  }
}