class UserModelDto {
  final int? id;
  final String? firstname;
  final String? lastname;
  final String? email;
  final String? roles;
  final String? adress;
  final String? profil;
  final String? date_naissance;
  final String? sexe;
  final String? phone;

  UserModelDto({this.id, this.firstname, this.phone,this.profil, this.lastname, this.email,this.roles,this.adress, this.date_naissance,this.sexe});

  factory UserModelDto.fromJson(Map<String, dynamic> json) {
    return UserModelDto(
      id: json['id'],
      firstname: json['FirstName'],
      lastname: json['LastName'],
      email: json['email'],
      roles: json['roles'][0],
      adress: json['Address'],
      date_naissance: json['Date_naissance'],
      profil: json['photo_profil'], 
      sexe: json['sexe'],
      phone: json['phone']
    );
  } 

}