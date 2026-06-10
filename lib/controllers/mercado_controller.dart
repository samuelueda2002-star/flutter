import 'dart:convert';
import 'package:http/http.dart' as http;

class CotacaoAgroModel {
  final String moeda;
  final double valorCompra;
  final String dataSincronizacao;

  CotacaoAgroModel({required this.moeda, required this.valorCompra, required this.dataSincronizacao});

  factory CotacaoAgroModel.fromJson(Map<String, dynamic> json) {
    return CotacaoAgroModel(
      moeda: json['name'] ?? 'Moeda Estrangeira',
      valorCompra: double.tryParse(json['bid']?.toString() ?? '0.0') ?? 0.0,
      dataSincronizacao: json['create_date'] ?? '',
    );
  }
}

class MercadoApiController {
  final String _endpoint = 'https://economia.awesomeapi.com.br/json/last/USD-BRL,EUR-BRL';

  Future<List<CotacaoAgroModel>> buscarCotacoesMercado() async {
    try {
      final response = await http.get(Uri.parse(_endpoint)).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final Map<String, dynamic> mapaJson = jsonDecode(response.body);
        List<CotacaoAgroModel> listaConvertida = [];
        
        if (mapaJson.containsKey('USDBRL')) listaConvertida.add(CotacaoAgroModel.fromJson(mapaJson['USDBRL']));
        if (mapaJson.containsKey('EURBRL')) listaConvertida.add(CotacaoAgroModel.fromJson(mapaJson['EURBRL']));
        
        return listaConvertida;
      }
      throw Exception('Servidor retornou erro código: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erro de rede ao ligar à API pública: $e');
    }
  }
}