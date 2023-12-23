import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class Chatbot extends StatefulWidget {
  const Chatbot({super.key});

  @override
  State<Chatbot> createState() => _ChatbotState();
}


String apiUrl = "https://sapdos-api.azurewebsites.net/api/Credentials/FeedbackJoiningBot";
Uri uri = Uri.parse(apiUrl);

Future<String> generateText(String prompt) async {
  final response = await http.post(
    uri,
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $apiUrl",
    },
    body: jsonEncode({
      "model": "text-davinci-003",
      "prompt": prompt,
      "max_tokens": 100,
      "temperature": 0.5
    }),
  );

  print(response.body);

  if (response.statusCode == 200) {
    final responseJson = jsonDecode(response.body);
    return responseJson['choices'][0]['text'].trim();
  } else {
    throw Exception("Failed to generate text");
  }
}


class _ChatbotState extends State<Chatbot> {

  final _textController = TextEditingController();
  final _messages = <String>[];

  void _sendMessage() async {
    String message = _textController.text;
    setState(() {
      _messages.add(message);
      _textController.clear();
    });

    String response = await _getResponse(message);
    setState(() {
      _messages.add(response);
    });
  }

  Future<String> _getResponse(String message) async {
    try {

      final response = await generateText(message);

      if (response == null) {
        print("Error: Empty response received from the API");
        return "Error generating response";
      }

      setState(() {
        _messages.add(response); // Add the API response
      });

      return response;
    } catch (e) {
      print("Error generating response: $e");
      return "Error generating response";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Welcome to CentraLogic",
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
                Text(
                  "Hi Charles",
                  style: TextStyle(color: Colors.black, fontSize: 14),
                ),
                Divider(),
              ],
            ),
          ),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          children: [
            Image(
              image: AssetImage("assets/img.png"),
              width: 50,
            ),
            Text(
              'CentraLogic Bot',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            Text(
              "Hi, I'm CentraLogic Bot",
              style: TextStyle(fontSize: 12),
            ),
            Flexible(
              child:  ListView(
                  children: _messages.map((message) => _buildMessage(message, false)).toList()
              ),
            ),
      Container(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                decoration: InputDecoration(
                  hintText: 'Type Your Message',
                  hintStyle: TextStyle(fontSize: 14),
                  filled: true,
                  fillColor: Colors.grey.shade300,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                ),
              ),
            ),
            SizedBox(width: 5),
            ElevatedButton(
              onPressed: _sendMessage,
              child: Text('Send', style: TextStyle(color: Colors.white, fontSize: 18)),
              style: ElevatedButton.styleFrom(
                primary: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            )
            ],
           ),
          ),
          ],
        ),
      ),
    );
  }
}


Widget _buildMessage(String message, bool isUser) {
  return Container(
    padding: EdgeInsets.all(8.0),
    margin: EdgeInsets.only(bottom: 8.0),
    decoration: BoxDecoration(
      color: isUser ? Colors.blue[200] : Colors.grey[200],
      borderRadius: BorderRadius.circular(8.0),
    ),
    child: Text(message),
  );
}