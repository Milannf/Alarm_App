// lib/pages/message.dart
import 'package:flutter/material.dart';

class MessagePage extends StatefulWidget {
  final String? initialMessage; // <--- PASTIKAN BARIS INI ADA

  const MessagePage({super.key, this.initialMessage}); // <--- PASTIKAN CONSTRUCTOR SEPERTI INI

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.initialMessage ?? ''; // <--- PASTIKAN BARIS INI ADA
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _saveMessage() {
    final message = _controller.text.trim();
    if (message.isNotEmpty) {
      Navigator.pop(context, message);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a message')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Message'),
        backgroundColor: Colors.black87,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              maxLines: 5,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                hintText: 'Enter your message here...',
                labelText: 'Alarm Message',
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveMessage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'Save Message',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}