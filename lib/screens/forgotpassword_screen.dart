import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class ForgotPasswordScreen extends StatelessWidget {
  ForgotPasswordScreen({super.key});

  final TextEditingController emailController = TextEditingController();

  Future<void> resetPassword(BuildContext context) async {
    final String baseUrl = Platform.isIOS
        ? 'http://localhost:5001/users/registration'
        : 'http://10.0.2.2:5001/users/registration';
    var response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({'email': emailController.text.trim()}),
    );

    if(response.statusCode == 201) {
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(
          email: emailController.text.trim(),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('E-mail de recuperação enviado!')),
        );
        Navigator.pop(context);
      } on FirebaseAuthException catch (e) {
        String message = '';
        if (e.code == 'user-not-found') {
          message = 'Usuário não encontrado';
        } else {
          message = 'Erro: ${e.message}';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('E-mail não registrado!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/BlackSemFrase.png',
              height: 350,
              width: 300,
            ),
            Expanded(
              child: Container(
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Recuperar Senha",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),
                      // Campo de Email
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      // Botão de Recuperar Senha
                      ElevatedButton(
                        onPressed: () => resetPassword(context),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 100, vertical: 15),
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'Enviar',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Link para voltar à tela de login
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context); // Volta para a tela de login
                        },
                        child: const Text(
                          "Lembrei minha senha",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
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
}