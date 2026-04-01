class Usuario {
  final String? id;
  final String nome;
  final String email;
  final String telefone;
  final String senha;

  Usuario({
    this.id,
    required this.nome,
    required this.email,
    required this.telefone,
    required this.senha,
  });

 
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'telefone': telefone,
      'senha': senha,
    };
  }
}