class EmployeeModel {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String? middleName;
  final String? avatar;
  final String? position;
  final String? team;
  final List<String> roles;

  EmployeeModel({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.middleName,
    this.avatar,
    this.position,
    this.team,
    required this.roles,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      middleName: json['middleName'],
      avatar: json['avatar'],
      position: json['position'] is Map ? json['position']['name'] : json['position'],
      team: json['team'] is Map ? json['team']['name'] : json['team'],
      roles: List<String>.from(json['roles'] ?? []),
    );
  }
}
