import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:research_writer/consts.dart';
import 'package:research_writer/message.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: const ColorScheme.light(
          primary: Colors.black,
        ),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController myController = TextEditingController();
  bool waiting = false;
  final List<Message> chat = [];
  late final GenerativeModel model;

  @override
  void initState() {
    super.initState();
    model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);
  }

  void _incrementCounter(String prompt) async {
    setState(() {
      chat.add(
          Message(sender: 'user', content: prompt, timestamp: DateTime.now()));
      waiting = true;
      myController.clear();
    });
    final content = [Content.text(prompt)];
    final response = await model.generateContent(content);

    setState(() {
      chat.add(Message(
          sender: 'bot',
          content: response.text ?? '',
          timestamp: DateTime.now()));
      waiting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: chat.length,
                itemBuilder: (context, index) {
                  if (chat[index].sender == 'user') {
                    return Text(chat[index].content,
                        style: const TextStyle(color: Colors.black38));
                  } else {
                    return Text(chat[index].content,
                        style: const TextStyle(color: Colors.black));
                  }
                },
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey.shade100,
              ),
              margin: const EdgeInsets.only(top: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: TextField(
                        controller: myController,
                        onSubmitted: (text) => _incrementCounter(text),
                        maxLines: 10,
                        minLines: 1,
                        keyboardType: TextInputType.multiline,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "Enter your prompt here...",
                        ),
                        style: const TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: waiting
                        ? null
                        : () => _incrementCounter(myController.text),
                    tooltip: 'Send Prompt',
                    icon: const Icon(Icons.send),
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
