import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'history_detail_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final AuthService _authService = AuthService();
  List<Map<String, dynamic>> _consultas = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final history = await _authService.getHistory();
      setState(() {
        _consultas = history ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erro ao carregar histórico: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Histórico Médico')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Histórico Médico')),
        body: Center(child: Text(_errorMessage!)),
      );
    }

    if (_consultas.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Histórico Médico')),
        body: const Center(child: Text('Nenhuma consulta encontrada')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Histórico Médico')),
      body: ListView.builder(
        itemCount: _consultas.length,
        itemBuilder: (ctx, i) {
          final c = _consultas[i];
          final codigo = c['ficha_codigo']?.toString() ?? 'N/A';
          final createdAt = c['created_at']?.toString();
          DateTime? data;
          try {
            data = createdAt != null ? DateTime.parse(createdAt) : null;
          } catch (e) {
            data = null;
          }

          final formattedDate = data != null
              ? '${data.day.toString().padLeft(2, '0')}/'
              '${data.month.toString().padLeft(2, '0')}/'
              '${data.year} às '
              '${data.hour.toString().padLeft(2, '0')}:'
              '${data.minute.toString().padLeft(2, '0')}'
              : 'Data inválida';

          return ListTile(
            title: Text('Ficha: $codigo'),
            subtitle: Text(formattedDate),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => HistoryDetailPage(consulta: c),
                ),
              );
            },
          );
        },
      ),
    );
  }
}