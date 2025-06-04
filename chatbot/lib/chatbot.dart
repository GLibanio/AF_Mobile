import 'package:flutter/material.dart';
import 'package:dialog_flowtter/dialog_flowtter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<String> mensagensIniciais = [
    "Olá! Como posso te ajudar hoje?",
    "Oi! O que você gostaria de conversar?",
    "Como está o seu dia?",
    "Tudo bem por aí? Me conta como posso ajudar.",
    "Oi! Quer compartilhar algo comigo hoje?",
  ];

  late DialogFlowtter dialogFlowtter;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  bool isTyping = false;
  String? userId;

  @override
  void initState() {
    super.initState();
    _initializeDialogFlowtter();
    _authenticateUser();
  }

  Future<void> _authenticateUser() async {
    try {
      final userCredential = await auth.signInAnonymously();
      setState(() {
        userId = userCredential.user?.uid;
      });
      _sendInitialBotMessage();
    } catch (e) {
      print('Erro ao autenticar: $e');
      setState(() {
        userId = 'erro'; // Para não ficar preso no loading
      });
    }
  }

  Future<void> _initializeDialogFlowtter() async {
    dialogFlowtter = await DialogFlowtter.fromFile();
  }

  void _sendInitialBotMessage() {
    final mensagemAleatoria =
        mensagensIniciais[Random().nextInt(mensagensIniciais.length)];
    _addMessage('bot', mensagemAleatoria);
  }

  Future<void> _addMessage(String sender, String text) async {
    if (userId == null) return;

    await firestore.collection('chats').doc(userId).collection('messages').add({
      'sender': sender,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> sendMessage(String userMessage) async {
    if (userMessage.trim().isEmpty) return;

    setState(() {
      isTyping = true;
    });

    await _addMessage('user', userMessage);

    try {
      final response = await dialogFlowtter.detectIntent(
        queryInput: QueryInput(
          text: TextInput(text: userMessage, languageCode: 'pt-BR'),
        ),
      );

      String botMessage = 'Não entendi, pode repetir?';
      if (response.message != null && response.message!.text != null) {
        botMessage = response.message!.text!.text![0];
      }

      await _addMessage('bot', botMessage);
    } catch (e) {
      await _addMessage('bot', 'Ocorreu um erro. Tente novamente.');
    } finally {
      if (mounted) {
        setState(() {
          isTyping = false;
        });
      }
    }
  }

  Widget buildMessage(Map<String, dynamic> message) {
    final bool isUser = message['sender'] == 'user';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: CircleAvatar(
                backgroundImage: AssetImage('assets/Lotus.png'),
                radius: 18,
              ),
            ),
          Flexible(
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUser ? Colors.blue[100] : Colors.white,
                borderRadius: BorderRadius.circular(15),
                border:
                    isUser
                        ? Border.all(color: Colors.transparent)
                        : Border.all(color: Colors.black87, width: 1.5),
              ),
              child: Text(
                message['text'] ?? '',
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),
          ),
          if (isUser)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: CircleAvatar(
                backgroundImage: AssetImage('assets/user_icon.png'),
                radius: 18,
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    dialogFlowtter.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF6F927C),
      appBar: AppBar(
        backgroundColor: Color(0xFF6F927C),
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Chat com Lótus",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body:
          userId == null
              ? Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream:
                          firestore
                              .collection('chats')
                              .doc(userId)
                              .collection('messages')
                              .orderBy('timestamp', descending: true)
                              .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Center(child: CircularProgressIndicator());
                        }

                        final messages = snapshot.data!.docs;

                        return ListView.builder(
                          padding: EdgeInsets.all(10),
                          itemCount: messages.length + (isTyping ? 1 : 0),
                          reverse: true,
                          itemBuilder: (context, index) {
                            if (isTyping && index == 0) {
                              return buildMessage({
                                'sender': 'bot',
                                'text': 'Lótus está digitando...',
                              });
                            }
                            final messageIndex = isTyping ? index - 1 : index;
                            return buildMessage(
                              messages[messageIndex].data()
                                  as Map<String, dynamic>,
                            );
                          },
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: TextField(
                              controller: _controller,
                              style: TextStyle(color: Colors.black),
                              decoration: InputDecoration(
                                hintText: "Digite aqui...",
                                hintStyle: TextStyle(color: Colors.black54),
                                border: InputBorder.none,
                              ),
                              onSubmitted: (value) {
                                if (value.trim().isNotEmpty) {
                                  sendMessage(value.trim());
                                  _controller.clear();
                                }
                              },
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.teal[400],
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(Icons.send, color: Colors.white),
                            onPressed: () {
                              final text = _controller.text.trim();
                              if (text.isNotEmpty) {
                                sendMessage(text);
                                _controller.clear();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }
}
