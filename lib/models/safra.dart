class Safra {
  final String id;
  final String talhao;
  final String cultura;
  final String status;
  final double area;

  Safra({
    required this.id,
    required this.talhao,
    required this.cultura,
    required this.status,
    required this.area,
  });

  factory Safra.fromMap(Map<String, dynamic> map) {
    return Safra(
      id: map['id'] ?? '',
      talhao: map['talhao'] ?? '',
      cultura: map['cultura'] ?? '',
      status: map['status'] ?? '',
      area: double.tryParse(map['area'].toString()) ?? 0.0,
    );
  }
}