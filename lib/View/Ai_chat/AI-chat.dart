import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class Ai_chat extends StatefulWidget {
  const Ai_chat({super.key});

  @override
  Ai_chat2 createState() => Ai_chat2();
}

class Ai_chat2 extends State<Ai_chat> {
  final RxBool toggleAvatar = RxBool(true);
  final String apiKey = "AIzaSyAg1Q2NbHQJLgpn3yFrBb6rxG3c86F5nQc";

  final types.User currenUser =
  const types.User(id: '1', firstName: 'user', lastName: '');

  types.User get gpt => types.User(
    id: '2',
    firstName: 'AI',
    lastName: '',
    imageUrl: toggleAvatar.value ? 'assets/ss.gif' : 'assets/ss.gif',
  );

  final List<types.Message> messages = <types.Message>[];

  @override
  void initState() {
    super.initState();
    toggleAvatar.value;
  }

  Widget _buildCustomAvatar(
      BuildContext context,
      types.User user, {
        double? width,
        double? height,
      }) {
    if (user.id == '2') {
      return Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            image: AssetImage(user.imageUrl ?? ''),
            fit: BoxFit.cover,
          ),
          boxShadow: [
            BoxShadow(color: Colors.black, blurRadius: 6, spreadRadius: 2),
          ],
        ),
      );
    }
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFF189CE0),
      ),
      child: Center(
        child: Text(
          user.firstName![0],
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Hi".tr, style: const TextStyle(color: Colors.black)),
            const SizedBox(width: 5),
            const Icon(Icons.waving_hand, color: Color(0xFFFAEBD7)),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFAEBD7),
            borderRadius: BorderRadius.circular(40),
          ),
          child: Chat(
            user: currenUser,
            messages: messages,
            theme: DefaultChatTheme(
              backgroundColor: Colors.transparent,
              inputBackgroundColor: Colors.white,
              primaryColor: const Color(0xFF189CE0),
              secondaryColor: Colors.white,
              inputTextColor: Colors.black,
              inputTextDecoration: InputDecoration.collapsed(
                  hintText: "Type your message".tr),
              inputTextStyle: const TextStyle(fontSize: 16),
              inputBorderRadius: BorderRadius.circular(20),
              inputPadding: const EdgeInsets.all(10),
              inputMargin: const EdgeInsets.only(
                  top: 10, bottom: 20, right: 10, left: 10),
              inputElevation: 2,
            ),
            onSendPressed: (types.PartialText message) {
              final textMessage = types.TextMessage(
                author: currenUser,
                createdAt: DateTime.now().millisecondsSinceEpoch,
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                text: message.text,
              );
              setState(() {
                messages.insert(0, textMessage);
              });
              getChatResponse(textMessage);
            },
            showUserAvatars: true,
            showUserNames: true,
          ),
        ),
      ),
    );
  }

  Future<void> getChatResponse(types.TextMessage m) async {
    try {
      final response = await sendToAPI(m.text);
      if (response != null) {
        setState(() {
          Timer.periodic(const Duration(hours: 12), (timer) {
            toggleAvatar.value = !toggleAvatar.value;
          });
          messages.insert(
            0,
            types.TextMessage(
              author: gpt,
              createdAt: DateTime.now().millisecondsSinceEpoch,
              text: response,
              id: DateTime.now().millisecondsSinceEpoch.toString(),
            ),
          );
        });
      }
    } catch (e) {
      setState(() {
        toggleAvatar.value = !toggleAvatar.value;
        messages.insert(
          0,
          types.TextMessage(
            author: gpt,
            createdAt: DateTime.now().millisecondsSinceEpoch,
            text: "${'Error'.tr}: $e",
            id: DateTime.now().millisecondsSinceEpoch.toString(),
          ),
        );
      });
    }
  }

  Future<String?> sendToAPI(String userInput) async {
    final url = Uri.parse(
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey");

    final body = jsonEncode({
      "contents": [
        {
          "parts": [
            {"text": userInput}
          ]
        }
      ]
    });

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['candidates'][0]['content']['parts'][0]['text'];
    } else {
      throw Exception(
          "Failed to connect: ${response.statusCode}, ${response.body}");
    }
  }
}