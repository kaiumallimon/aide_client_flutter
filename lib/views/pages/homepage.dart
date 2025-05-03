import 'package:aide_client/models/ai_agent_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<AiAgentModel>? agents;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadAgents(); // Call the async function without await
  }

 Future<void> loadAgents() async {
  setState(() {
    isLoading = true;
  });

  try {
    // Fetch agents from Supabase
    final response = await Supabase.instance.client
        .from('agents')
        .select('id, name, description, system_prompt, vectorstore_id, created_by, created_at');

    if (response == null || response is! List) {
      throw Exception('Invalid response from agents table');
    }

    // Cast response to List<Map<String, dynamic>>
    final List<Map<String, dynamic>> loadedAgents = List<Map<String, dynamic>>.from(response);

    // Fetch each creator profile and construct AiAgentModel
    final parsedAgents = await Future.wait(loadedAgents.map((agent) async {
      final creatorResponse = await Supabase.instance.client
          .from('profiles')
          .select('full_name')
          .eq('id', agent['created_by'])
          .maybeSingle();

      // Use fallback in case profile isn't found
      final profile = creatorResponse ?? {};

      return AiAgentModel(
        id: agent['id'],
        name: agent['name'],
        description: agent['description'],
        systemPrompt: agent['system_prompt'],
        vectorstoreId: agent['vectorstore_id'],
        createdBy: agent['created_by'],
        createdAt: DateTime.parse(agent['created_at']),
        creatorName: profile['full_name'] ?? 'Unknown',
      );
    }).toList());

    setState(() {
      agents = parsedAgents;
      isLoading = false;
    });
  } catch (e) {
    print('Error loading agents: $e');
    setState(() {
      isLoading = false;
    });
  }
}



  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available agents:',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 10),
        IconButton(
          onPressed: () async {
            await loadAgents();
          },
          icon: Icon(Icons.refresh, color: Colors.white),
        ),
        const SizedBox(height: 10),
    
        if (isLoading)
          Expanded(
            child: Center(
              child: CupertinoActivityIndicator(
                color: Colors.grey,
                radius: 15,
              ),
            ),
          )
        else if (agents!.isEmpty)
          Text('No agents found.')
        else
          Expanded(
            child: ListView.builder(
              itemCount: agents!.length,
              itemBuilder: (context, index) {
                final agent = agents![index];
                return ExpansionTile(
                  leading: Icon(
                    Icons.support_agent,
                    color: Colors.deepOrange,
                  ),
                  title: Text(
                    agent.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  subtitle: Text(
                    agent.description,
                    style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                  ),
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      width: double.infinity,
                      color: Colors.grey[900],
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "System Prompt:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.deepOrange,
                            ),
                          ),
                          Text(
                            agent.systemPrompt,
                            style: TextStyle(color: Colors.white),
                          ),
                          SizedBox(height: 10),
    
                          Text(
                            "Created By:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.deepOrange,
                            ),
                          ),
                          Text(
                            agent.creatorName,
                            style: TextStyle(color: Colors.white),
                          ),
    
                          SizedBox(height: 10),
    
                          Text(
                            "Created At:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.deepOrange,
                            ),
                          ),
                          Text(
                            agent.createdAt.toLocal().toString(),
                            style: TextStyle(color: Colors.white),
                          ),
    
                          if (agent.vectorstoreId != null) ...[
                            SizedBox(height: 10),
                            Text(
                              "Vector Store ID:",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.deepOrange,
                              ),
                            ),
                            Text(
                              agent.vectorstoreId!,
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
      ],
    );
  }
}
