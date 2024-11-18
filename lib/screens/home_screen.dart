import 'package:flutter/material.dart';
import 'package:invisto_app/services/lesson-service.dart';
import '../services/coin-service.dart';
import 'lesson_screen.dart';
import 'investment_screen.dart'; // Importe a InvestmentScreen

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final CoinService _coinService;
  late final LessonService _lessonService;
  List<dynamic> lessons = [];
  late int qtdInvicoin;

  @override
  void initState() {
    super.initState();
    _coinService = CoinService();
    _lessonService = LessonService();
    _getCoin();
    allLessons();
  }

  Future<void> _getCoin() async {
    final coin = await _coinService.fetchUserCoins();
    if (coin != null) {
      setState(() {
        qtdInvicoin = coin;
      });
      print("Sucesso ao buscar as moedas.");
    } else {
      print("Erro ao buscar as moedas.");
    }
  }

  Future<void> allLessons() async {
    final fetchedLessons = await _lessonService.getAllLessons();
    if (fetchedLessons != null) {
      setState(() {
        lessons = fetchedLessons;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Center(
          child: Image.asset(
            'assets/images/BlackSemFrase.png',
            height: 100,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle, size: 30),
            onPressed: () {
              // Função ao clicar no ícone de perfil
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.purple[700],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Suas próximas aulas',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 10),

            Container(
              color: Colors.purple[200],
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Container(
                height: 150,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  itemCount: lessons.length,
                  itemBuilder: (context, index) {
                    final lesson = lessons[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: _buildClassCard(lesson),
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Suas simulações de investimentos',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 10),

            Container(
              color: Colors.purple[200],
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              child: _buildInvestmentSimulation(),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => InvestmentScreen()),
                    );
                  },
                  child: Text('Investimentos'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassCard(dynamic lesson) {
    return AspectRatio(
      aspectRatio: 1,
      child: Material(
        color: Colors.purple[700],
        borderRadius: BorderRadius.circular(100),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LessonScreen(subject: lesson['subject']),
              ),
            );
          },
          splashColor: Colors.purple[300],
          highlightColor: Colors.purple[200],
          borderRadius: BorderRadius.circular(100),
          child: Center(
            child: Text(
              "Aula ${lesson['subject']}",
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInvestmentSimulation() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Variação: 5%",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Rentabilidade: 12%",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 10),
            Icon(Icons.show_chart, color: Colors.green, size: 80),
          ],
        ),
      ),
    );
  }
}
