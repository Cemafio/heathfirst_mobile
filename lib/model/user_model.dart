class UserModel {
  final int id;
  final String firstname;
  final String lastname;
  final String email;
  final String roles;
  final String adress;
  final String profil;

  UserModel({required this.id, required this.firstname,required this.profil, required this.lastname, required this.email,required this.roles,required this.adress});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      firstname: json['FirstName'],
      lastname: json['LastName'],
      email: json['email'],
      roles: json['roles'][0],
      adress: json['Address'],
      profil: json['photo_profil'] 
    );
  }

  // UserModel copyWith({String? firstname, String? lastname,String? email,String? roles, String? adress}) {
  //   return UserModel(
  //     id: id,
  //     firstname: firstname ?? this.firstname,
  //     lastname: lastname ?? this.lastname,
  //     email: email ?? this.email,
  //     roles: roles ?? this.roles,
  //     adress: adress ?? this.adress
  //   );
  // }
}