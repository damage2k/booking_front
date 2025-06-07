class UserModel {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String? middleName;
  final String? avatar;
  final String? position;
  final List<String> roles;
  final Map<String, dynamic>? team;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.middleName,
    this.avatar,
    this.position,
    required this.roles,
    this.team,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      middleName: json['middleName'],
      avatar: json['avatar'],
      position: json['position'],
      roles: List<String>.from(json['roles'] ?? []),
      team: json['team'],
    );
  }
}
