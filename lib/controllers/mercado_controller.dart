import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// Modelo de Dados para encapsular e tipar a resposta da API pública
class CotacaoModel {
  final String nome;
  final double valorCompra;
  final double valorVenda;
  final double variacao;
  final double porcentagemAlteracao;
  final String dataAtualizacao;

  CotacaoModel({
    required this.nome,
    required this.valorCompra,
    required this.valorVenda,
    required this.variacao,
    required this.porcentagemAlteracao,
    required this.dataAtualizacao,
  });

  /// Converte a estrutura JSON da API de forma segura e tipada
  factory CotacaoModel.fromJson(Map<String, dynamic> json) {
    return CotacaoModel(
      nome: json['name'] ?? 'Moeda Indefinida',
      valorCompra: double.tryParse(json['bid']?.toString() ?? '0.0') ?? 0.0,
      valorVenda: double.tryParse(json['ask']?.toString() ?? '0.0') ?? 0.0,
      variacao: double.tryParse(json['varBid']?.toString() ?? '0.0') ?? 0.0,
      porcentagemAlteracao: double.tryParse(json['pctChange']?.toString() ?? '0.0') ?? 0.0,
      dataAtualizacao: json['create_date'] ?? 'Data não informada',
    );
  }
}

class MercadoApiController {
  // URL da API Pública Sem Exigência de Token/Chaves
  final String _endpointUrl = 'https://economia.awesomeapi.com.br/json/last/USD-BRL,EUR-BRL';

  /// RF007: Consome a API pública externa tratando os estados assíncronos e erros com precisão
  Future<List<CotacaoModel>> buscarCotacoesAgro() async {
    try {
      // Executa a requisição GET com timeout preventivo de 10 segundos
      final response = await http.get(Uri.parse(_endpointUrl)).timeout(
        const Duration(seconds: 10),
      );

      // Código HTTP 200 indica sucesso na comunicação
      if (response.statusCode == 200) {
        final Map<String, dynamic> dadosJson = jsonDecode(response.body);
        
        List<CotacaoModel> cotacoesCarregadas = [];

        // Mapeia e adiciona o Dólar à lista se o nó existir
        if (dadosJson.containsKey('USDBRL')) {
          cotacoesCarregadas.add(CotacaoModel.fromJson(dadosJson['USDBRL']));
        }
        
        // Mapeia e adiciona o Euro à lista se o nó existir
        if (dadosJson.containsKey('EURBRL')) {
          cotacoesCarregadas.add(CotacaoModel.fromJson(dadosJson['EURBRL']));
        }

        return cotacoesCarregadas;
      } else {
        // Trata respostas com erro vindo do servidor
        throw Exception('O servidor de cotações respondeu com código de erro: ${response.statusCode}');
      }
    } catch (e) {
      // Trata problemas de falta de conexão com a internet ou timeouts
      throw Exception('Falha ao sincronizar indicadores econômicos. Verifique sua conexão. Detalhes: $e');
    }
  }
}