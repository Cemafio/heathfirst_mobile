class Patient {
  int id;
  String first_name;
  String last_name;
  String email;
  String adress;
  String photo;

  Patient({
    required this.id,
    required this.last_name,
    required this.first_name,
    required this.email,
    required this.photo,
    required this.adress
  });

  factory Patient.fromJson(Map<String, dynamic> patient) {
    return Patient(
      id: patient['id'],
      last_name: patient['LastName'] ?? '',
      first_name: patient['FirstName'] ?? '',
      email: patient['email'] ?? '',
      photo: patient['photo_profil'] ?? patient['photoProfil'],
      adress: patient['Address'] ?? '',
    );
  }
}