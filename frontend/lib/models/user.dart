class User {
  final int? id;
  final String name;
  final String email;
  final String? password;
  final String? role;
  final DateTime? emailVerifiedAt;
  final String? rememberToken;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    this.id,
    required this.name,
    required this.email,
    this.password,
     this.role,
    this.emailVerifiedAt,
    this.rememberToken,
    this.createdAt,
    this.updatedAt,
  });

  // Create a copy of the user with updated fields
  User copyWith({
    int? id,
    String? name,
    String? email,
    String? password,
    String? role,
    DateTime? emailVerifiedAt,
    String? rememberToken,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      rememberToken: rememberToken ?? this.rememberToken,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
bool operator ==(Object other) {
  if (identical(this, other)) return true;
  
  return other is User &&
      other.id == id &&
      other.name == name &&
      other.email == email &&
      other.password == password &&
      other.role == role &&
      other.emailVerifiedAt == emailVerifiedAt &&
      other.rememberToken == rememberToken &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt;
}

@override
int get hashCode {
  return id.hashCode ^
      name.hashCode ^
      email.hashCode ^
      password.hashCode ^
      role.hashCode ^
      emailVerifiedAt.hashCode ^
      rememberToken.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode;
}
}