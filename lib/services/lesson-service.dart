import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class LessonService {
  final String baseUrl = Platform.isIOS
      ? 'http://localhost:5001/lessons'
      : 'http://10.0.2.2:5001/lessons';

  Future<dynamic> getLesson(String subject) async {
    final response = await http.post(
      Uri.parse('$baseUrl/lesson'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'subject': subject}),
    );

    final data = json.decode(response.body);

    return data;
  }

  Future<List<dynamic>> getAllLessons() async {
    final response = await http.get(
      Uri.parse('$baseUrl/lessons'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is Map && data.containsKey('lessons')) {
        return data['lessons'] as List<dynamic>;
      } else {
        throw Exception("Formato de dados inválido: a chave 'lessons' não foi encontrada.");
      }
    } else {
      throw Exception("Erro ao buscar aulas: ${response.statusCode}");
    }
  }


}