import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
void main() {
  runApp(MyRecipeApp());
}

class MyRecipeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recipe App',
      theme: ThemeData(
        primaryColor: const Color.fromARGB(255, 18, 19, 19),
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.grey, // Use the same color as primarySwatch for accentColor
        ).copyWith(
          secondary: const Color.fromARGB(255, 75, 76, 77), // Set the secondary color as accentColor
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: RecipeChatScreen(),
    );
  }
}




class RecipeChatScreen extends StatefulWidget {
  @override
  _RecipeChatScreenState createState() => _RecipeChatScreenState();
}

class _RecipeChatScreenState extends State<RecipeChatScreen> {
  TextEditingController _textController = TextEditingController();
  List<String> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _messages.add('ChatGPT: Hi! I am your recipe assistant. Please enter the ingredients you have, and I will suggest recipes for you.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recipe Chat'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _messages.clear();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              reverse: true, // Reverse the list to display messages from bottom to top
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if(_isTyping&& index==0){
                  return Align(
                    alignment: Alignment.centerLeft,
                      child: Container(
                        width: 50.0,
                        height: 50.0,
                        child: CircularProgressIndicator(),
                      ),
                  );
                }
                return _buildMessageBubble(_messages[index - (_isTyping ? 1 : 0)]);
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Enter ingredients...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.0),
                FloatingActionButton(
                  child: Icon(Icons.send),
                  onPressed: () {
                    _sendMessage(_textController.text);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String message) {
    final isUserMessage = message.startsWith('User:'); // You can define your own condition here

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Row(
        mainAxisAlignment: isUserMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: isUserMessage ? Color.fromARGB(255, 97, 195, 224) : Color.fromARGB(255, 252, 252, 252), // Set colors for user and reply messages
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.0),
                topRight: Radius.circular(12.0),
                bottomLeft: isUserMessage ? Radius.circular(12.0) : Radius.circular(0.0), // Adjust border radius based on message type
                bottomRight: isUserMessage ? Radius.circular(0.0) : Radius.circular(12.0), // Adjust border radius based on message type
              ),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7, // Set maximum width for message bubbles
              ),
            child: Text(
              message,
              style: TextStyle(color: Colors.black),
              softWrap: true,
            ),
          ),
          ),
        ],
      ),
    );
  }



Future<String> getChatGPTResponse(String message) async {
  const String apiKey = 'my_api_key'; // Replace with your actual API key
  const String endpoint = 'https://api.openai.com/v1/chat/completions';
  final Map<String, dynamic> body = {
    'model': 'gpt-3.5-turbo', // Use the ChatGPT model you prefer
    'messages': [
    {'role': 'system', 'content': 'You are an AI assistant that suggests recipes based on the ingredients provided by the user.'},
    {'role': 'user', 'content': message}],
    'max_tokens': 250, // Adjust based on the desired length of the response
  };

  final http.Response response = await http.post(
    Uri.parse(endpoint),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    },
    body: jsonEncode(body),
  );

  if (response.statusCode == 200) {
  final Map<String, dynamic> data = jsonDecode(response.body);
  print('response: $data');

  return data['choices'][0]['message']['content'].toString();
} else {
  throw Exception('Failed to fetch response from ChatGPT API with status code ${response.statusCode} and response body ${response.body}');
}
}
  void _sendMessage(String message) async {
  setState(() {
    _messages.insert(0, 'User: $message'); // Insert user message in the chat
    _isTyping = true;
  });

  try {
    String response = await getChatGPTResponse(message);
    setState(() {
      _messages.insert(0, 'ChatGPT: $response'); // Insert ChatGPT response in the chat
      _isTyping = false;
    });
  } catch (e) {
    print('Error: $e');
    // Handle error
  }

  _textController.clear();
}

}
