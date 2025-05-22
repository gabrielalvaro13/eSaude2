// models.dart
import 'dart:convert';

class Ficha {
  final String codigo, nome, cpf, sus;
  Ficha({required this.codigo, required this.nome, required this.cpf, required this.sus});
  factory Ficha.fromJson(Map<String, dynamic> j) => Ficha(
      codigo: j['codigo'], nome: j['nome'], cpf: j['cpf'] ?? '', sus: j['sus'] ?? ''
  );
}

class Triagem {
  final String queixaPrincipal, classificacaoRisco;
  final List<String>? comorbidades;
  // ... demais campos
  Triagem({
    required this.queixaPrincipal,
    required this.classificacaoRisco,
    this.comorbidades,
    // ...
  });
  factory Triagem.fromJson(Map<String, dynamic> j) => Triagem(
    queixaPrincipal: j['queixa_principal'],
    classificacaoRisco: j['classificacao_risco'],
    comorbidades: j['comorbidades'] != null
        ? List<String>.from(j['comorbidades'])
        : null,
    // ...
  );
}

class Diagnostico {
  final String cid, descricao;
  Diagnostico({required this.cid, required this.descricao});
  factory Diagnostico.fromJson(Map<String, dynamic> j) => Diagnostico(
      cid: j['cid'], descricao: j['descricao']
  );
}

class MedicamentoPrescrito {
  final String codigo, principioAtivo, frequencia;
  final int duracao;
  MedicamentoPrescrito({
    required this.codigo,
    required this.principioAtivo,
    required this.frequencia,
    required this.duracao,
  });
  factory MedicamentoPrescrito.fromJson(Map<String, dynamic> j) {
    final med = j['medicamento'] ?? {};
    return MedicamentoPrescrito(
      codigo: j['codigo'],
      principioAtivo: med['principio_ativo'] ?? '',
      frequencia: j['frequencia'],
      duracao: j['duracao'],
    );
  }
}

class Consulta {
  final int id;
  final DateTime createdAt, dataHoraSaida;
  final String procedimentos, condutas, prescricoes;
  final List<Diagnostico> diagnosticos;
  final List<MedicamentoPrescrito> medicamentos;

  Consulta({
    required this.id,
    required this.createdAt,
    required this.dataHoraSaida,
    required this.procedimentos,
    required this.condutas,
    required this.prescricoes,
    required this.diagnosticos,
    required this.medicamentos,
  });

  factory Consulta.fromJson(Map<String, dynamic> j) => Consulta(
    id: j['id'],
    createdAt: DateTime.parse(j['created_at']),
    dataHoraSaida: DateTime.parse(j['data_hora_saida']),
    procedimentos: j['procedimentos'] ?? '',
    condutas: j['condutas'] ?? '',
    prescricoes: j['prescricoes'] ?? '',
    diagnosticos: (j['diagnosticos'] as List)
        .map((e) => Diagnostico.fromJson(e)).toList(),
    medicamentos: (j['medicamentos'] as List)
        .map((e) => MedicamentoPrescrito.fromJson(e)).toList(),
  );
}

class Atendimento {
  final Ficha ficha;
  final Triagem? triagem;
  final List<Consulta> consultas;
  Atendimento({required this.ficha, this.triagem, required this.consultas});
  factory Atendimento.fromJson(Map<String, dynamic> j) => Atendimento(
    ficha: Ficha.fromJson(j['ficha']),
    triagem: j['triagem'] != null ? Triagem.fromJson(j['triagem']) : null,
    consultas: (j['consultas'] as List)
        .map((e) => Consulta.fromJson(e)).toList(),
  );
}
