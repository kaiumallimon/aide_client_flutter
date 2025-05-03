import 'dart:convert';
import 'package:aide_client/views/widgets/custom_button.dart';
import 'package:aide_client/views/widgets/custom_textfield.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreateAgentPage extends StatefulWidget {
  const CreateAgentPage({super.key});

  @override
  State<CreateAgentPage> createState() => _CreateAgentPageState();
}

class _CreateAgentPageState extends State<CreateAgentPage> {
  String? currentUserId;
  String? currentUserName;
  bool isLoading = false;
  bool isCreating = false;

  final TextEditingController _idController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  final TextEditingController _agentNameController = TextEditingController();
  final TextEditingController _agentDescriptionController =
      TextEditingController();
  final TextEditingController _agentPromptController = TextEditingController();

  @override
  void initState() {
    super.initState();
    currentUserId = dotenv.env['CURRENT_USER_ID'];
    _idController.text = currentUserId ?? '';
    fetchUserName();
  }

  Future<void> fetchUserName() async {
    setState(() => isLoading = true);

    final response =
        await Supabase.instance.client
            .from('profiles')
            .select('full_name')
            .eq('id', currentUserId!)
            .maybeSingle();

    setState(() {
      currentUserName = response?['full_name'] ?? 'Unknown';
      _nameController.text = currentUserName!;
      isLoading = false;
    });
  }

  Future<void> createAgent() async {
    String agent_name = _agentNameController.text.toString().trim();
    String agent_description =
        _agentDescriptionController.text.toString().trim();
    String agent_prompt = _agentPromptController.text.toString().trim();

    if (agent_name.isEmpty ||
        agent_description.isEmpty ||
        agent_prompt.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.deepOrange,
          content: Text(
            'Please fill all the required data.',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      );
      return;
    }

    setState(() {
      isCreating = true;
    });

    final url = Uri.parse('http://127.0.0.1:5000/api/admin/create-agent/');

    final Map<String, dynamic> data = {
      "name": agent_name,
      "description": agent_description,
      "system_prompt": agent_prompt,
      "created_by": currentUserId,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              'Agent created successfully!',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
        // Optionally clear input fields
        _agentNameController.clear();
        _agentDescriptionController.clear();
        _agentPromptController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              'Failed to create agent. ${response.body}',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Error: $e', style: TextStyle(color: Colors.white)),
        ),
      );
    } finally {
      setState(() {
        isCreating = false;
      });
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child:
            isLoading
                ? const Center(
                  child: CupertinoActivityIndicator(
                    radius: 15,
                    color: Colors.grey,
                  ),
                )
                : Center(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "You're currently logged in as:",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(height: 20),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.all(0),
                          child: Row(
                            children: [
                              _buildReadOnlyField(
                                controller: _nameController,
                                hintText: 'Full Name',
                                icon: Icons.account_circle_rounded,
                              ),
                              const SizedBox(width: 20),
                              _buildReadOnlyField(
                                controller: _idController,
                                hintText: 'User ID',
                                icon: Icons.verified_user_outlined,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        CustomTextfield(
                          controller: _agentNameController,
                          hintText: "Agent Name",
                          width: 620,
                        ),

                        const SizedBox(height: 20),
                        CustomTextfield(
                          controller: _agentDescriptionController,
                          hintText: "Agent Description",
                          width: 620,
                          height: 200,
                          expandable: true,
                        ),

                        const SizedBox(height: 20),
                        CustomTextfield(
                          controller: _agentPromptController,
                          hintText: "System Prompt",
                          width: 620,
                          height: 200,
                          // maxLine: 10,
                          expandable: true,
                        ),

                        const SizedBox(height: 20),
                        CustomButton(
                          width: 620,
                          height: 50,
                          onPressed: ()async {
                            await createAgent();
                          },
                          text: "Create Agent",
                          isLoading: isCreating,
                        ),
                      ],
                    ),
                  ),
                ),
      ),
    );
  }

  Widget _buildReadOnlyField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
  }) {
    return SizedBox(
      width: 300,
      height: 60,
      child: TextFormField(
        controller: controller,
        readOnly: true,
        style: const TextStyle(fontSize: 16, color: Colors.white),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
          filled: true,
          fillColor: Colors.grey.shade900,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(0),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          prefixIcon: Icon(icon, color: Colors.grey),
        ),
      ),
    );
  }
}
