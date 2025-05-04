import 'dart:convert';
import 'package:aide_client/models/message_model.dart';
import 'package:aide_client/utils/token_checker.dart';
import 'package:aide_client/views/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;

class UserChatProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  final TextEditingController messageController = TextEditingController();
  void clearMessageField() {
    messageController.clear();
  }

  static const String _agentId = "1caa981e-562c-492d-af1d-b4f954c46d78";
  bool isSending = false;

  final List<Message> _messages = [];
  List<Message> get messages => _messages;

  Future<void> sendMessage(BuildContext context, String conversationId) async {
    if (await isAccessTokenExpired()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Session expired. Please log in again."),
          backgroundColor: Colors.red,
        ),
      );

      final pref = await SharedPreferences.getInstance();
      await pref.clear();

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );

      return;
    }
    final content = messageController.text.trim();
    if (content.isEmpty) return;

    final pref = await SharedPreferences.getInstance();
    final userId = pref.getString('user_id');
    final accessToken = pref.getString('access_token');

    if (userId == null || accessToken == null) {
      debugPrint("Missing user_id or access_token");
      return;
    }

    final url = Uri.parse("http://127.0.0.1:5000/api/user/chat/");

    final body = jsonEncode({
      "user_id": userId,
      "agent_id": _agentId,
      "content": content,
      "conversation_id": conversationId,
    });

    try {
      isSending = true;
      notifyListeners();

      // Add user message immediately
      final userMessage = Message(
        id: null,
        conversationId: conversationId,
        role: 'user',
        content: content,
        metadata: null,
        timestamp: DateTime.now(),
      );
      _messages.add(userMessage);
      notifyListeners();

      messageController.clear();

      // Add temporary loading message from agent
      final loadingMessage = Message(
        id: null,
        conversationId: conversationId,
        role: 'agent',
        content: '...',
        metadata: {'loading': true},
        timestamp: DateTime.now(),
      );
      _messages.add(loadingMessage);
      notifyListeners();

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: body,
      );

      // Remove loading message
      _messages.remove(loadingMessage);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        debugPrint("Response: $data");

        // Optional: Replace local user message with the saved one from DB
        final savedUserMessage = Message.fromJson(data['stored_message']);
        _messages[_messages.indexWhere(
              (m) => m.timestamp == userMessage.timestamp,
            )] =
            savedUserMessage;

        // Add real agent response
        final aiMessage = Message(
          id: null,
          conversationId: data['conversation_id'],
          role: 'agent',
          content: data['llm_response'] ?? "No response",
          metadata: null,
          timestamp: DateTime.now(),
        );
        _messages.add(aiMessage);
        notifyListeners();
      } else {
        debugPrint("Failed to send message: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to send message"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      _messages.removeWhere((msg) => msg.metadata?['loading'] == true);
      debugPrint("Error sending message: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    } finally {
      isSending = false;
      notifyListeners();
    }
  }

  Future<void> fetchMessages(
    String conversationId,
    BuildContext context,
  ) async {
    try {
      if (await isAccessTokenExpired()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Session expired. Please log in again."),
            backgroundColor: Colors.red,
          ),
        );

        final pref = await SharedPreferences.getInstance();
        await pref.clear();

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );

        return;
      }
      isLoading = true;
      _messages.clear();
      notifyListeners();

      final response = await Supabase.instance.client
          .from('messages')
          .select()
          .eq('conversation_id', conversationId);

      final List<Map<String, dynamic>> loadedMessages =
          List<Map<String, dynamic>>.from(response);

      final parsedMessages =
          loadedMessages.map((message) => Message.fromJson(message)).toList();

      _messages.addAll(parsedMessages);
      notifyListeners();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error fetching messages: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
