class User {

  final String? email;
  final String? phoneNumber;
  final String? uid;
  final AuthenticationMode mode;

  const User({
   this.email,
   this.phoneNumber,
   this.uid,
   this.mode = AuthenticationMode.none,
});
}

enum AuthenticationMode {
  email,
  phoneNumber,
  none;

  @override
  String toString() {
    switch(this) {
      case AuthenticationMode.email:
        return 'email';
      case AuthenticationMode.phoneNumber:
        return 'phoneNumber';
      default:
        return 'none';
    }
  }

  static AuthenticationMode parse(String? value) {
    switch(value) {
      case 'email':
        return AuthenticationMode.email;
      case 'phoneNumber':
        return AuthenticationMode.phoneNumber;
      default:
        return AuthenticationMode.none;
    }
  }
}