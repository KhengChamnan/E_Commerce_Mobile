import '../../models/user.dart'; // Adjust the import according to your project structure

class UserDto {
  // Convert User instance to JSON map for API requests
  static Map<String, dynamic> toJson(User user) {
    return {
      'id': user.id,
      'name': user.name,
      'email': user.email,
      'password': user.password,
      'role': user.role,
      'email_verified_at': user.emailVerifiedAt?.toIso8601String(),
      'remember_token': user.rememberToken,
      'created_at': user.createdAt?.toIso8601String(),
      'updated_at': user.updatedAt?.toIso8601String(),
    };
  }

  // Create User instance from JSON map received from API
  static User fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      password: json['password'],
      role: json['role'] ?? 'user', // default role
      emailVerifiedAt: json['email_verified_at'] != null
          ? DateTime.parse(json['email_verified_at'])
          : null,
      rememberToken: json['remember_token'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  // Convert a list of JSON maps to a list of User objects
  static List<User> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => fromJson(json)).toList();
  }

  // Create JWT token claims from User
  static Map<String, dynamic> getJWTCustomClaims(User user) {
    return {
      'name': user.name,
      'email': user.email,
      'role': user.role,
    };
  }

  // Create User for registration request
  static Map<String, dynamic> toRegistrationJson(User user) {
    return {
      'name': user.name,
      'email': user.email,
      'password': user.password,
      'role': user.role,
    };
  }

  // Create User for registration request with password confirmation
  static Map<String, dynamic> toRegistrationWithConfirmationJson(User user, String passwordConfirmation) {
    return {
      'name': user.name,
      'email': user.email,
      'password': user.password,
      'password_confirmation': passwordConfirmation,
      'role': user.role ?? 'user', // Default to 'user' if role is null
    };
  }

  // Create User for login request
  static Map<String, dynamic> toLoginJson(String email, String password) {
    return {
      'email': email,
      'password': password,
    };
  }
}