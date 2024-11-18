import 'package:flutter/material.dart';
import 'dart:async';
import '../services/coin-service.dart';
import 'home_screen.dart';

class QuizScreen extends StatefulWidget {
  final Map<String, dynamic> quizData;
  QuizScreen({super.key, required this.quizData});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late final CoinService _coinService;
  late int qtdInvicoin = 0;
  late String lessonTopic;
  late int addCoins;
  late String question;
  late List<Map<String, dynamic>> options;
  Color color = Colors.deepPurpleAccent;
  Map<String, dynamic>? selectedOption;
  int countdown = 3;
  bool showAnswers = false;

  @override
  void initState() {
    super.initState();
    _coinService = CoinService();
    _getCoin();
    startCountdown();

    final quiz = widget.quizData['quiz'];
    addCoins = quiz['addCoins'] ?? 0;
    lessonTopic = quiz['subject'] ?? '';
    question = quiz['question'] ?? '';
    options = (quiz['answers'] as List<dynamic>).map((answer) => (answer as Map<String, dynamic>)).toList();
  }

  void startCountdown() {
    Timer.periodic(Duration(seconds: 1), (Timer timer) {
      setState(() {
        if (countdown > 1) {
          countdown--;
        } else {
          countdown = 0;
          showAnswers = true;
          timer.cancel();
        }
      });
    });
  }

  bool confirmarResposta(Map<String, dynamic>? resposta) {
    return resposta?['isTrue'] ?? false;
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
      body: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.purpleAccent, Colors.purple],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Quiz Invisto',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: 20),
            Text(
              lessonTopic,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 30),
            Text(
              question,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: showAnswers
                  ? ListView.builder(
                itemCount: options.length,
                itemBuilder: (context, index) {
                  return Card(
                    color: selectedOption == options[index] ? color : Colors.white,
                    child: ListTile(
                      title: Text(
                        options[index]['answer1'], // Corrigir o índice caso necessário
                        style: TextStyle(fontSize: 18),
                      ),
                      onTap: () {
                        setState(() {
                          selectedOption = options[index];
                        });
                      },
                    ),
                  );
                },
              )
                  : Center(
                child: Text(
                  countdown > 0 ? "$countdown" : "Começando...",
                  style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: selectedOption != null
                  ? () {
                if(confirmarResposta(selectedOption)){
                  //RESPOSTA CERTA
                  _addCoins(addCoins);
                }else{
                  //RESPOSTA ERRADA
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Você errou... Mais sorte na próxima...')),);
                }
                //Chamar tela de Home
                Future.delayed(Duration(seconds: 1), (){
                  Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                  );
                });
                setState(() {
                  color = confirmarResposta(selectedOption) ? Colors.green : Colors.red;
                });
                print("Resposta confirmada: $selectedOption");
              }
                  : null,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.greenAccent,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                'Confirmar Resposta',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
