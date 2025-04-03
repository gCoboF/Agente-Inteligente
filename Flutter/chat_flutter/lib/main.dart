import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'dart:async';
import 'package:typewritertext/typewritertext.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const ChatPage(),
    );
  }
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<Message> _messages = [];
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;

  Future<void> _sendMessage(String text) async {
    if (text.isEmpty) return;

    setState(() {
      _messages.add(Message(text: text, isUser: true));
      _isLoading = true;
    });
    _controller.clear();  // Moved here to clear immediately after showing user's message

    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/generate'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'query': text,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(utf8.decode(response.bodyBytes));
        print('API Response: $responseData'); // Add this line to debug
        setState(() {
          _messages.add(Message(
            text: responseData['Gemini'] ?? 'No response received',
            isUser: false
          ));
        });
      } else {
        setState(() {
          _messages.add(Message(
            text: 'Error: ${response.statusCode}',
            isUser: false
          ));
        });
      }
    } catch (e) {
      print('Error sending message: $e');
      setState(() {
        _messages.add(Message(
          text: 'Error: Could not connect to server',
          isUser: false
        ));
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: const Color(0xff007367),
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: const Color(0xFFe5f1f0),
              child: Image.network(
                'https://static.vecteezy.com/system/resources/previews/017/378/923/non_2x/cute-little-baby-capybara-being-sweet-vector.jpg',
                height: 25,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.person,
                    color: Color(0xff007367),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xff007367)),
                  );
                },
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'UFABara',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage('https://i.pinimg.com/736x/b5/9d/a0/b59da055421d0625c54f9195b6b1c9be.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                reverse: true,
                padding: const EdgeInsets.all(8),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages.reversed.toList()[index];
                  return MessageBubble(message: message);
                },
              ),
            ),
            if (_isLoading)
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 190, 243, 239),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: LoadingAnimationWidget.waveDots(
                    color: const Color(0xff007367),
                    size: 35,
                  ),
                ),
              ),
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.grey[100]?.withOpacity(0.9),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      onSubmitted: (text) => _sendMessage(text),
                      decoration: const InputDecoration(
                        hintText: 'Digite sua mensagem...',
                        contentPadding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(25.0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(25.0)),
                          borderSide: BorderSide(color: Color(0xff007367)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(25.0)),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FloatingActionButton(
                    onPressed: () => _sendMessage(_controller.text),
                    backgroundColor: const Color(0xff007367),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50.0), 
                    ),
                    child: const Icon(Icons.send, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ); 
  }
}

class Message {
  final String text;
  final bool isUser;

  Message({required this.text, required this.isUser});
}

class MessageBubble extends StatefulWidget {
  final Message message;

  const MessageBubble({super.key, required this.message});

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  late TypeWriterController _controller;
  String _displayText = '';

  @override
  void initState() {
    super.initState();
    _displayText = widget.message.text;
    _controller = TypeWriterController(
      text: _displayText,
      duration: const Duration(milliseconds: 25),
    );
  }

  @override
  void didUpdateWidget(MessageBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.message.text != widget.message.text) {
      _displayText = widget.message.text;
      _controller = TypeWriterController(
        text: _displayText,
        duration: const Duration(milliseconds: 25),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: widget.message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: widget.message.isUser ? const Color(0xff007367) : const Color.fromARGB(255, 190, 243, 239),
          borderRadius: BorderRadius.circular(20),
        ),
        child: widget.message.isUser
            ? Text(
                widget.message.text,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.3,
                  color: Colors.white,
                ),
                softWrap: true,
                textAlign: TextAlign.left,
              )
            : TypeWriter(
                controller: _controller,
                builder: (context, value) {
                  return Text(
                    value.text,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.3,
                      color: Colors.black,
                    ),
                    softWrap: true,
                    textAlign: TextAlign.left,
                  );
                },
              ),
      ),
    );
  }
}
