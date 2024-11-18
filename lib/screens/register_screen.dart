import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  final _cpf = TextEditingController();
  final _dob = TextEditingController();
  final _phone = TextEditingController();

  bool _isLoading = false;

  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Dados do formulário
      Map<String, String> body = {
        'name': _name.text,
        'email': _email.text,
        'password': _password.text,
        'cpf': _cpf.text,
        'birth': _dob.text,
        'phone': _phone.text,
        'confirmedPassword': _confirmPassword.text
      };

      final String baseUrl = Platform.isIOS
          ? 'http://localhost:5001/users/registration'
          : 'http://10.0.2.2:5001/users/registration';

      // Chamada à API
      var response = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        var jsonResponse = jsonDecode(response.body);

        // Se o cadastro for bem-sucedido, autenticar usuário
        _authenticateUser(_email.text, _password.text);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Conta criada com sucesso!'),
        ));
        Navigator.pop(context);

        //Com o cadastro bem-sucedido, chamar a função da API que adiciona o UID no banco de dados

          //Pegar o uid do usuário logado
          var userUid = FirebaseAuth.instance.currentUser?.uid;
          var userEmail = FirebaseAuth.instance.currentUser?.email;
          //Criando body do request
          Map<String, String?> bodyRequest = {
            'uid':userUid,
            'email':userEmail
          };

          // Chamada à API
          var responseUid = await http.post(
            Uri.parse('http://localhost:5001/users/addUidUser'),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(bodyRequest),
          );

          if(responseUid.statusCode == 201){
            // Sucesso
          }else{
            // Tratar erros
            var jsonResponse = jsonDecode(responseUid.body);
            var message = jsonResponse['error'] ?? 'Erro, entre em contato com o suporte!';
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(message),
            ));
          }

      } else {
        // Tratar erros
        var jsonResponse = jsonDecode(response.body);
        var message = jsonResponse['error'] ?? 'Erro, entre em contato com o suporte!';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(message),
        ));
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _authenticateUser(String email, String password) async {
    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erro ao autenticar: $e'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SingleChildScrollView( // Permite rolar a tela
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Botão de Voltar no canto superior esquerdo
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(top: 40.0), // Aumentado para 40
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Voltar',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
            ),

            // Logo e título
            const SizedBox(height: 10),
            Image.asset(
              'assets/images/BlackSemFrase.png',
              height: 150, // Altura do logo
              width: 200,
            ),
            const SizedBox(height: 10),

            // Container roxo com gradiente e formulário
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.elliptical(125, 5),
                  topRight: Radius.elliptical(300, 250),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.purpleAccent, Colors.purple],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                // Formulário de registro
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(height: 15),
                      _buildTextField(_name, 'Nome Completo'),
                      const SizedBox(height: 20),
                      _buildTextField(_email, 'Email'),
                      const SizedBox(height: 20),
                      _buildPasswordField(_password, 'Senha'),
                      const SizedBox(height: 20),
                      _buildPasswordField(_confirmPassword, 'Confirmação de Senha'),
                      const SizedBox(height: 20),
                      _buildTextField(_cpf, 'CPF'),
                      const SizedBox(height: 20),
                      _buildTextField(_dob, 'Data de nascimento'),
                      const SizedBox(height: 20),
                      _buildTextField(_phone, 'Telefone'),
                      const SizedBox(height: 30),
                      _isLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                        onPressed: _registerUser,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 100, vertical: 15),
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'Criar conta',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Função para criar campos de texto
  Widget _buildTextField(TextEditingController controller, String labelText) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor, insira $labelText';
        }
        return null;
      },
    );
  }

  // Função para criar campos de senha
  Widget _buildPasswordField(
      TextEditingController controller, String labelText) {
    return TextFormField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor, insira $labelText';
        }
        return null;
      },
    );
  }
}