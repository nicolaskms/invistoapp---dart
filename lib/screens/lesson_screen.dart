import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:invisto_app/screens/quiz_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:invisto_app/services/lesson-service.dart';
import 'package:invisto_app/services/quiz-service.dart';

import '../services/coin-service.dart';

class LessonScreen extends StatefulWidget {
  late final String subject;
  LessonScreen({required this.subject});

  @override
  _LessonPageState createState() => _LessonPageState();
}

class _LessonPageState extends State<LessonScreen> {
  late final CoinService _coinService;
  late final LessonService _lessonService;
  late final QuizService _quizService;
  String title = '';
  String introduction = '';
  String content = '';
  late int qtdInvicoin = 0;

  @override
  void initState() {
    super.initState();
    _coinService = CoinService();
    _lessonService = LessonService();
    _quizService = QuizService();
    _getCoin();
    fetchLessonData();
  }

  // Função para buscar os dados da aula da API
  Future<void> fetchLessonData() async {
    final lesson = await _lessonService.getLesson(widget.subject);
    if (lesson != null && lesson.containsKey('lesson')) {
      setState(() {
        title = lesson['lesson']['title'];
        introduction = lesson['lesson']['introduction'];
        content = lesson['lesson']['content'];
      });
    } else {
      print("Erro ao carregar os dados.");
    }
  }

  Future<void> _addCoins(int coins) async {
    final success = await _coinService.fetchAddCoin(coins);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Você acertou e ganhou $coins Invicoins!')),
      );
    } else {
      print("Erro ao adicionar as moedas.");
    }
  }

  Future<void> _getCoin() async {
    final coin = await _coinService.fetchUserCoins();
    if(coin != null) {
      qtdInvicoin = coin;
    } else {
      print("Erro ao buscar as moedas.");
    }
  }

  Future<Map<String, dynamic>> fetchQuiz() async {
    final quiz = await _quizService.gerQuiz(widget.subject);
    if(quiz != null) {
      return quiz;
    } else {
      throw Exception('Erro ao carregar o quiz');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Image.asset(
          'assets/images/BlackSemFrase.png',
          height: 100,
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Row(
              children: [
                Text(
                  qtdInvicoin.toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(width: 6),
                Image.asset(
                  'assets/images/invicoin.png',
                  height: 25,
                  width: 25,
                ),
              ],
            ),
          ),
        ],
        backgroundColor: Colors.grey[300],
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.purple,
          width: double.infinity,
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                title.isEmpty ? 'TÍTULO DA AULA' : title.toUpperCase(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      introduction.isEmpty ? 'INTRODUÇÃO' : introduction,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      content.isEmpty ? 'CONTEÚDO' : content,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      await _addCoins(50);
                      Navigator.of(context).pop();
                    },
                    child: Text('ENCERRAR'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      _addCoins(50);
                      try {
                        final quizData = await fetchQuiz();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QuizScreen(quizData: quizData),
                          ),
                        );
                      } catch (e) {
                        print('Erro ao carregar o quiz: $e');
                      }
                    },
                    child: Text('QUIZ'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}