class UserProfile {
  final String name;
  final String email;
  final DateTime joinedAt;

  const UserProfile({
    required this.name,
    required this.email,
    required this.joinedAt,
  });

  String get initials => name
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .take(2)
      .map((part) => part[0])
      .join()
      .toUpperCase();
}
