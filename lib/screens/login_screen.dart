import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:invisto_app/screens/register_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home_screen.dart'; // Importação do Firebase Auth
import 'forgotpassword_screen.dart'; // Importação da tela de recuperação de senha

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> loginUser(BuildContext context) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      // Se o login for bem-sucedido, você pode navegar para outra tela, por exemplo
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login realizado com sucesso!')),
      );
      // Navegar para outra tela ou fazer algo após login
      Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );

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
        Uri.parse('http://10.0.2.2:5001/users/adduid'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(bodyRequest),
      );

      if(responseUid.statusCode == 200){
        // Sucesso
        print('UID ADICIONADA COM SUCESSO!');
      }else{
        // Tratar erros
        var jsonResponse = jsonDecode(responseUid.body);
        var message = jsonResponse['error'] ?? 'Uid Erro, entre em contato com o suporte!';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(message),
        ));
      }
    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'user-not-found') {
        message = 'Usuário não encontrado';
      } else if (e.code == 'wrong-password') {
        message = 'Senha incorreta';
      } else {
        message = 'Erro: ${e.message}';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300], // Cor do fundo da tela
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/sloganpreto.png',
              height: 350,
              width: 300,
            ),

            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.elliptical(125, 5),
                        topRight: Radius.elliptical(300, 250)
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.purpleAccent,
                        Colors.purple
                      ],
                    )
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Já tem uma conta? Faça Seu login",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),
                      // Campo de Email
                      TextField(
                        controller: emailController, // Controller para email
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
                      // Campo de Senha
                      TextField(
                        controller: passwordController, // Controller para senha
                        obscureText: true,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Senha',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      // Botão de Entrar
                      ElevatedButton(
                        onPressed: () => loginUser(context),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 100, vertical: 15),
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'Entrar',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Links para criar conta e esquecer senha
                      GestureDetector(
                        onTap: () {
                          // Navegar para a RegisterScreen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => RegisterPage()),
                          );
                        },
                        child: const Text(
                          "Não tem uma conta? Crie aqui",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () {
                          // Navegar para a tela de recuperação de senha
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ForgotPasswordScreen()),
                          );
                        },
                        child: const Text(
                          "Esqueci minha senha!",
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
