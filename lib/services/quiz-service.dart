import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class QuizService {
  final String baseUrl = Platform.isIOS
      ? 'http://localhost:5001/quizzes'
      : 'http://10.0.2.2:5001/quizzes';

  Future<dynamic> gerQuiz(String subject) async {
    final response = await http.post(
      Uri.parse('$baseUrl/quiz'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'subject': subject}),
    );
    final data = json.decode(response.body);

    return data;
  }
}