class Permission{
  final int permissionId;
  final String permissionName;

  Permission({
    required this.permissionId,
    required this.permissionName
  });

  factory Permission.fromJson(Map<String , dynamic> json){
    return Permission(permissionId: json['permissionId'], permissionName: json['permissionName']);
  }
}