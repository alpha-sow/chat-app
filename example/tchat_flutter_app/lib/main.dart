import 'package:flutter/material.dart';
import 'package:tchat_app/tchat_app.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Discussion _discussion;

  @override
  void initState() {
    super.initState();
    _discussion = Discussion(
      title: 'Flutter Demo Chat',
      participants: ['user1', 'user2'],
    );
    _discussion.addMessage('user1', 'Welcome to the tchat_app demo!');
  }

  @override
  void dispose() {
    _discussion.dispose();
    super.dispose();
  }

  void _addMessage() {
    setState(() {
      _discussion.addMessage(
        'user1',
        'Message ${_discussion.messages.length + 1}',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Discussion: ${_discussion.title}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _discussion.messages.length,
              itemBuilder: (context, index) {
                final message = _discussion.messages[index];
                return ListTile(
                  title: Text('${message.senderId}:'),
                  subtitle: Text(message.content),
                  trailing: Text(
                    '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Messages: ${_discussion.messages.length}'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMessage,
        tooltip: 'Add Message',
        child: const Icon(Icons.message),
      ),
    );
  }
}
