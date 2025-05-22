import 'package:flutter/material.dart';

class HistoryDetailPage extends StatelessWidget {
  final Map<String, dynamic> consulta;

  const HistoryDetailPage({Key? key, required this.consulta}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final createdAt = consulta['created_at']?.toString();
    DateTime? data;
    try {
      data = createdAt != null ? DateTime.parse(createdAt) : null;
    } catch (e) {
      data = null;
    }

    final formattedDate = data != null
        ? '${data.day.toString().padLeft(2, '0')}/'
        '${data.month.toString().padLeft(2, '0')}/'
        '${data.year} '
        '${data.hour.toString().padLeft(2, '0')}:'
        '${data.minute.toString().padLeft(2, '0')}'
        : 'Data inválida';

    return Scaffold(
      appBar: AppBar(title: const Text('Detalhe da Consulta')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Data: $formattedDate', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text('Procedimentos: ${consulta['procedimentos']?.toString() ?? '-'}'),
              const SizedBox(height: 8),
              Text('Condutas: ${consulta['condutas']?.toString() ?? '-'}'),
              const SizedBox(height: 8),
              Text('Prescrições: ${consulta['prescricoes']?.toString() ?? '-'}'),
              const SizedBox(height: 16),
              if (consulta['diagnosticos'] != null && consulta['diagnosticos'] is List) ...[
                const Text('Diagnósticos:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...(consulta['diagnosticos'] as List<dynamic>).map((d) {
                  if (d is Map<String, dynamic>) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text('• [${d['cid']?.toString() ?? 'N/A'}] ${d['descricao']?.toString() ?? '-'}'),
                    );
                  }
                  return const SizedBox.shrink();
                }).toList(),
                const SizedBox(height: 16),
              ],
              if (consulta['medicamentos'] != null && consulta['medicamentos'] is List) ...[
                const Text('Medicamentos:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...(consulta['medicamentos'] as List<dynamic>).map((m) {
                  if (m is Map<String, dynamic> && m['medicamento'] is Map<String, dynamic>) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        '• ${m['medicamento']['principio_ativo']?.toString() ?? 'N/A'} - '
                            'Freq: ${m['frequencia']?.toString() ?? '-'}, '
                            'Duração: ${m['duracao']?.toString() ?? '-'} dias',
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }).toList(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}