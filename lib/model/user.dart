class UserModel {
  String id;
  String email;
  String password;
  String name;

  UserModel({
    required this.id,
    required this.email,
    required this.password,
    required this.name,
  });

  factory UserModel.fromMap(Map<dynamic, dynamic> map, String id) {
    return UserModel(
      id: id,
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      name: map['name'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'password': password,
      'name': name,
    };
  }
}
