// pages/atendimento_page.dart
import 'package:flutter/material.dart';
import '../models.dart';
import '../services/consulta_service.dart';

class AtendimentoPage extends StatefulWidget {
  final String fichaCodigo;
  const AtendimentoPage({Key? key, required this.fichaCodigo}) : super(key: key);

  @override
  _AtendimentoPageState createState() => _AtendimentoPageState();
}

class _AtendimentoPageState extends State<AtendimentoPage> {
  late Future<Atendimento> _futureAtendimento;

  @override
  void initState() {
    super.initState();
    _futureAtendimento = ConsultaService.fetchAtendimento(widget.fichaCodigo);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Atendimento: ${widget.fichaCodigo}')),
      body: FutureBuilder<Atendimento>(
        future: _futureAtendimento,
        builder: (ctx, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Erro: ${snap.error}'));
          }
          final at = snap.data!;
          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ficha
                Text('Ficha', style: Theme.of(context).textTheme.titleLarge),
                Text('Código: ${at.ficha.codigo}'),
                Text('Nome: ${at.ficha.nome}'),
                Text('CPF: ${at.ficha.cpf}'),
                Text('SUS: ${at.ficha.sus}'),
                SizedBox(height: 16),

                // Triagem
                if (at.triagem != null) ...[
                  Text('Triagem', style: Theme.of(context).textTheme.titleLarge),
                  Text('Queixa: ${at.triagem!.queixaPrincipal}'),
                  // .. demais campos
                  SizedBox(height: 16),
                ],

                // Consultas
                for (var c in at.consultas) ...[
                  Divider(),
                  Text(
                    'Consulta em ${c.createdAt.day}/${c.createdAt.month}/${c.createdAt.year} '
                        '${c.createdAt.hour}:${c.createdAt.minute.toString().padLeft(2,'0')}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text('Saída: ${c.dataHoraSaida}'),
                  Text('Procedimentos: ${c.procedimentos}'),
                  Text('Condutas: ${c.condutas}'),
                  Text('Prescrições: ${c.prescricoes}'),
                  if (c.diagnosticos.isNotEmpty) ...[
                    Text('Diagnósticos:', style: TextStyle(fontWeight: FontWeight.bold)),
                    for (var d in c.diagnosticos)
                      Text('• ${d.cid} — ${d.descricao}'),
                  ],
                  if (c.medicamentos.isNotEmpty) ...[
                    Text('Medicamentos:', style: TextStyle(fontWeight: FontWeight.bold)),
                    for (var m in c.medicamentos)
                      Text('• ${m.principioAtivo} (${m.frequencia} por ${m.duracao} dia(s))'),
                  ],
                  SizedBox(height: 12),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

