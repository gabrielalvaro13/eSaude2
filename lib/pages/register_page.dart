import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String email = '';
  String password = '';
  String confirm = '';
  String cpf = '';
  String cartasSus = '';
  bool _loading = false;

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final ok = await AuthService().register(
      name: name,
      email: email,
      password: password,
      cpf: cpf.isEmpty ? null : cpf,
      cartasSus: cartasSus.isEmpty ? null : cartasSus,
    );
    setState(() => _loading = false);
    if (ok) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha no registro.')),
      );
    }
  }

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      appBar: AppBar(title: Text('Registro')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Nome'),
                onChanged: (v) => name = v,
                validator: (v) => v!.isEmpty ? 'Informe o nome' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'E-mail'),
                onChanged: (v) => email = v,
                validator: (v) => v!.contains('@') ? null : 'E-mail inválido',
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Senha'),
                obscureText: true,
                onChanged: (v) => password = v,
                validator: (v) => v!.length >= 6 ? null : 'Mínimo 6 caracteres',
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Confirme a Senha'),
                obscureText: true,
                onChanged: (v) => confirm = v,
                validator: (v) => v != password ? 'Senhas não conferem' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'CPF (opcional)'),
                onChanged: (v) => cpf = v,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Cartas SUS (opcional)'),
                onChanged: (v) => cartasSus = v,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? CircularProgressIndicator()
                    : Text('Registrar'),
              ),
              SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pushReplacementNamed(ctx, '/login'),
                child: Text('Já tenho conta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
