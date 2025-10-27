class LoginResponse {
  final String token;
  final int role;
  final String userId;
  final String? companyId;

  LoginResponse({
    required this.token,
    required this.role,
    required this.userId,
    this.companyId,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> j) => LoginResponse(
        token: j['token'],
        role: j['role'],
        userId: j['userId'],
        companyId: j['companyId'],
      );
}

class MeResponse {
  final String id;
  final String email;
  final int role;
  final String? companyId;
  final bool active;

  MeResponse({
    required this.id,
    required this.email,
    required this.role,
    required this.active,
    this.companyId,
  });

  factory MeResponse.fromJson(Map<String, dynamic> j) => MeResponse(
        id: j['id'],
        email: j['email'],
        role: j['role'],
        companyId: j['companyId'],
        active: j['active'],
      );
}
