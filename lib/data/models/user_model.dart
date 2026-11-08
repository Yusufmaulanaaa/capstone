class AppUser {
  final String name;
  final String email;
  final String? photoUrl;
  final String provider; // email | google

  const AppUser({
    required this.name,
    required this.email,
    required this.provider,
    this.photoUrl,
  });
}
