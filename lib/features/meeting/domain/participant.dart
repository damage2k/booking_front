class Participant {
  final String username;
  final String firstName;
  final String lastName;
  final String? middleName;
  final String? avatar;

  Participant({
    required this.username,
    required this.firstName,
    required this.lastName,
    this.middleName,
    this.avatar,
  });

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      username: json['username'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      middleName: json['middleName'],
      avatar: json['avatar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'firstName': firstName,
      'lastName': lastName,
      'middleName': middleName,
      'avatar': avatar,
    };
  }
}
