// services/consulta_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models.dart';

class ConsultaService {
  static const _baseUrl = 'https://smartcidade.com/api';

  static Future<Atendimento> fetchAtendimento(String uuid) async {
    final res = await http.get(Uri.parse('$_baseUrl/consultas/$uuid'));
    if (res.statusCode == 200) {
      return Atendimento.fromJson(json.decode(res.body));
    } else {
      throw Exception('Erro ao buscar atendimento');
    }
  }
}
