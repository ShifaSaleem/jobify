class Users {
  final String id;
  final String name;
  final String email;
  final String? profileImage;
  final String password;
  final String? bio;
  final List<String>? skills;
  final String? contact;


  Users({
    required this.id,
    required this.name,
    required this.email,
    this.profileImage,
    required this.password,
    this.bio,
    this.skills,
    this.contact,
  });
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'profile_image': profileImage,
      'bio': bio,
      'skills': skills,
      'contact': contact,
    };
  }

  factory Users.fromMap(Map<String, dynamic> map, String id) {
    return Users(
      id: id,
      name: map['name'],
      email: map['email'],
      profileImage: map['profile_image'],
      bio: map['bio'],
      skills: List<String>.from(map['skills'] ?? []),
      contact: map['contact'],
      password: '',
    );
  }
}