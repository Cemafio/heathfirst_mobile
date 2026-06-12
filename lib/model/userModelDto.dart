class UserModelDto {
  final int? id;
  final String? firstname;
  final String? lastname;
  final String? email;
  final String? roles;
  final String? adress;
  final String? profil;

  UserModelDto({this.id, this.firstname,this.profil, this.lastname, this.email,this.roles,this.adress});

  factory UserModelDto.fromJson(Map<String, dynamic> json) {
    return UserModelDto(
      id: json['id'],
      firstname: json['FirstName'],
      lastname: json['LastName'],
      email: json['email'],
      roles: json['roles'][0],
      adress: json['Address'],
      profil: json['photo_profil'] 
    );
  }

}