
class User {
  final int? id ; 
  final String username ;
  final String password ; 
  final String email ;
  final String number ; 

  const User({
    this.id,
    required this.username,
    required this.password,
    required this.email,
    required this.number
  });

  User copyWith({
    int? id,
    String? username,
    String? password,
    String? email,
    String? number,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
      email: email ?? this.email,
      number: number ?? this.number,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'username': username,
      'password': password,
      'email': email,
      'number': number,
    };
  }

  factory User.fromMap(Map<String, dynamic> map){
    return User(
      id: map['id'] as int?,
      username: map['username'] as String,
      password: map['password'] as String, 
      email: map['email'] as String,
      number: map['number'] as String
    );
  }

  @override
  String toString() {
    return 'User(id: $id, username: $username, email: $email, number: $number)';
  }
}