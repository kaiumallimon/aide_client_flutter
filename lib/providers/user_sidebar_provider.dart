import 'package:aide_client/models/conversation_model.dart';
import 'package:aide_client/views/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserSidebarProvider extends ChangeNotifier {
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  List<Conversation> _conversations = [];

  List<Conversation> get conversations => _conversations;
  // Optionally expose conversation ID
  String? get currentConversationId => _currentConversation?.id;
  
  
  Future<void> fetchConversations() async {
    final pref = await SharedPreferences.getInstance();
    final userId = pref.getString('user_id') ?? '';
    final response = await Supabase.instance.client
        .from('conversations')
        .select()
        .eq('user_id', userId);
    final List<Map<String, dynamic>> loadedConversations =
        List<Map<String, dynamic>>.from(response);

    // parse to the model
    final parsedConversations =
        loadedConversations.map((conversation) {
          return Conversation.fromJson(conversation);
        }).toList();

    _conversations = parsedConversations;
    notifyListeners();
  }

  Future<void> logout(BuildContext context) async {
    final pref = await SharedPreferences.getInstance();
    await pref.clear();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  Conversation? _currentConversation;

  Conversation? get currentConversation => _currentConversation;

  set currentConversation(Conversation? conversation) {
    _currentConversation = conversation;
    notifyListeners();
  }
}
