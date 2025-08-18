
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];

  Future<void> _sendMessage(String msg) async {
    setState(() {
      _messages.add({"user": msg});
    });

    final response = await http.post(
      Uri.parse("https://openrouter.ai/api/v1/chat/completions"),
      headers: {
        "Authorization": "Bearer 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",
        "Content-Type": "application/json"
      },
      body: jsonEncode({
        "model": "mistralai/mistral-7b-instruct",
        "messages": [
          {"role": "user", "content": msg}
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final answer = data['choices'][0]['message']['content'];
      setState(() {
        _messages.add({"bot": answer});
      });
    } else {
      setState(() {
        _messages.add({"bot": "Erro ao obter resposta da IA."});
      });
    }

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: const Text('Chat IA - Alagamentos'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (_, i) {
                final msg = _messages[i];
                final isUser = msg.containsKey("user");
                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue[300] : Colors.grey[850],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      isUser ? msg["user"]! : msg["bot"]!,
                      style: TextStyle(
                          color: isUser ? Colors.black : Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Digite sua pergunta...",
                      hintStyle: const TextStyle(color: Colors.white60),
                      border: const OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white24),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.cyanAccent),
                  onPressed: () => _sendMessage(_controller.text),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
