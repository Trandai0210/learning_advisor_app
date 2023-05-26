class User{
  final int userId;
  final String name;
  final String gmail;
  final String phone;
  final String image;
  final String dob;
  final bool status;
  final int permissionId;
  final String permissionName;
  User({
    required this.userId,
    required this.name,
    required this.gmail,
    required this.phone,
    required this.image,
    required this.dob,
    required this.status,
    required this.permissionId,
    required this.permissionName
  });

  factory User.fromJson(Map<String, dynamic> json){
    return User(
      userId: json['userId'], 
      name: json['name'], 
      gmail: json['gmail'], 
      phone: json['phone'], 
      image: json['image'], 
      dob: json['dob'], 
      status: json['status'],
      permissionId: json['permissionId'],
      permissionName: json['permissionName']
    );
  }
}