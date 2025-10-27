class CompanyDto {
  final String id;
  final String name;
  final String nit;
  final String? logoUrl;
  final bool active;
  final DateTime createdAt;

  CompanyDto({
    required this.id,
    required this.name,
    required this.nit,
    required this.logoUrl,
    required this.active,
    required this.createdAt,
  });

  factory CompanyDto.fromJson(Map<String, dynamic> j) => CompanyDto(
        id: j['id'],
        name: j['name'],
        nit: j['nit'],
        logoUrl: j['logoUrl'],
        active: j['active'],
        createdAt: DateTime.parse(j['createdAt']),
      );
}
