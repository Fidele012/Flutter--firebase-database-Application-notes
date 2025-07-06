class AppUser {
  final String uid;
  final String email;

  AppUser({required this.uid, required this.email});

  factory AppUser.fromFirebaseUser(user) {
    return AppUser(uid: user.uid, email: user.email ?? '');
  }
}