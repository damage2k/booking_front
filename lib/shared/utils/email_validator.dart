class EmailValidator {
  static bool isValid(String value) {
    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
    return emailRegex.hasMatch(value);
  }
}
