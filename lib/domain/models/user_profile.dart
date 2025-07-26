class UserProfile {
  final String uid;
  final String name;
  final String surname;
  final String? plate;
  final String? photoBase64;
  final String? phone;
  final List<String> favoriteIds;

  UserProfile({
    required this.uid,
    required this.name,
    required this.surname,
    this.plate,
    this.photoBase64,
    this.phone,
    this.favoriteIds = const [],
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'surname': surname,
        'plate': plate,
        'photoBase64': photoBase64,
        'phone': phone,
        'favoriteIds': favoriteIds,
      };

  static UserProfile fromMap(String uid, Map<String, dynamic> map) {
    return UserProfile(
      uid: uid,
      name: map['name'] ?? '',
      surname: map['surname'] ?? '',
      plate: map['plate'],
      photoBase64: map['photoBase64'],
      phone: map['phone'],
      favoriteIds: List<String>.from(map['favoriteIds'] ?? [])
    );
  }
}


