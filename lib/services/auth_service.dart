import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final String _baseUrl = 'https://smartcidade.com/api/patient';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// Registra um novo paciente
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String? cpf,
    String? cartasSus,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': password,
        if (cpf != null) 'cpf': cpf,
        if (cartasSus != null) 'cartas_sus': cartasSus,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      await _storage.write(key: 'token', value: data['token']);
      return true;
    }
    return false;
  }

  /// Autentica paciente existente
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _storage.write(key: 'token', value: data['token']);
      return true;
    }
    return false;
  }

  /// Envia link de recuperação de senha para o e-mail
  Future<bool> sendResetLink({required String email}) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/password/email'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
    return response.statusCode == 200;
  }

  /// Reseta a senha usando token
  Future<bool> resetPassword({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/password/reset'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'token': token,
        'password': password,
        'password_confirmation': passwordConfirmation,
      }),
    );
    return response.statusCode == 200;
  }

  /// Obtém dados do paciente logado
  Future<Map<String, dynamic>?> getUser() async {
    final token = await _storage.read(key: 'token');
    if (token == null) return null;

    final response = await http.get(
      Uri.parse('$_baseUrl/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    return null;
  }

  /// Busca o histórico de consultas do paciente logado
  Future<List<Map<String, dynamic>>> getHistory() async {
    final token = await _storage.read(key: 'token');
    if (token == null) throw Exception('Usuário não autenticado');

    final response = await http.get(
      Uri.parse('$_baseUrl/history'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      // 1) Decodifica como Map
      final Map<String, dynamic> jsonMap =
      jsonDecode(response.body) as Map<String, dynamic>;

      // 2) Extrai a lista sob a chave 'consultas'
      final List<dynamic> listaDinamica =
          jsonMap['consultas'] as List<dynamic>? ?? [];

      // 3) Converte cada item para Map<String, dynamic>
      return listaDinamica
          .map((e) => e as Map<String, dynamic>)
          .toList();
    } else {
      throw Exception(
          'Erro ao carregar histórico (status: ${response.statusCode})');
    }
  }

  /// Busca todas as consultas médicas do paciente
  Future<List<Map<String, dynamic>>> getConsultas() async {
    final token = await _storage.read(key: 'token');
    if (token == null) throw Exception('Usuário não autenticado');

    final response = await http.get(
      Uri.parse('$_baseUrl/consultas'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> lista = jsonDecode(response.body);
      return lista.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Erro ao carregar consultas (status: ${response.statusCode})');
    }
  }

  /// Busca detalhes de uma consulta específica pelo código da ficha
  Future<Map<String, dynamic>> getConsultaByFicha(String fichaCodigo) async {
    final token = await _storage.read(key: 'token');
    if (token == null) throw Exception('Usuário não autenticado');

    final uri = Uri.parse('$_baseUrl/consultas/$fichaCodigo');
    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Erro ao carregar consulta (status: ${response.statusCode})');
    }
  }

  /// Efetua logout do paciente
  Future<void> logout() async {
    final token = await _storage.read(key: 'token');
    if (token != null) {
      await http.post(
        Uri.parse('$_baseUrl/logout'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      await _storage.delete(key: 'token');
    }
  }

  /// Retorna token salvo
  Future<String?> getToken() async => _storage.read(key: 'token');
}
