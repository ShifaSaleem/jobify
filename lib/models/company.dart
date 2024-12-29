class Company {
  final String id;
  final String name;
  final String email;
  final String? logo;
  final String bio;
  final String website;
  final String contact;
  final String location;

  Company({
    required this.id,
    required this.name,
    required this.email,
    this.logo,
    required this.bio,
    required this.website,
    required this.contact,
    required this.location,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'logo': logo,
      'bio': bio,
      'website': website,
      'contact': contact,
      'location': location,
    };
  }

  factory Company.fromMap(Map<String, dynamic> map, String id) {
    return Company(
      id: id,
      name: map['name'],
      email: map['email'],
      logo: map['logo'],
      bio: map['bio'],
      website: map['website'],
      contact: map['contact'],
      location: map['location'],
    );
  }
}