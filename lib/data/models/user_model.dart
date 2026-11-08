class AppUser {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final String provider; // email | google

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.provider,
    this.photoUrl,
  });

  factory AppUser.fromJson(Map<String, dynamic> j) => AppUser(
        id: '${j['id'] ?? ''}',
        name: '${j['name'] ?? ''}',
        email: '${j['email'] ?? ''}',
        provider: '${j['provider'] ?? 'email'}',
        photoUrl: j['photoUrl']?.toString(),
      );

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'email': email, 'provider': provider, 'photoUrl': photoUrl};
}
