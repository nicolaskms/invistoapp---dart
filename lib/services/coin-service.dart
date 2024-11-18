import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

String? uid = FirebaseAuth.instance.currentUser?.uid;

class CoinService {
  final String baseUrl = Platform.isIOS
      ? 'http://localhost:5001/users'
      : 'http://10.0.2.2:5001/users';

  Future<bool> fetchAddCoin(int coins) async {


    final response = await http.post(
      Uri.parse('$baseUrl/addcoins'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'uid': uid, 'coins': coins}),
    );

    return response.statusCode == 200;
  }

  Future<int?> fetchUserCoins() async {

    final response = await http.post(
      Uri.parse('$baseUrl/getuserdata'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'uid': uid}),
    );

    if (response.statusCode == 201) {
      final responseData = json.decode(response.body);
      return responseData['data']['coin'];
    } else {
      print("Erro ao buscar o saldo de moedas.");
      return null;
    }
  }

}
