import 'package:aide_client/providers/user_sidebar_provider.dart';
import 'package:aide_client/views/pages/user_chat_page.dart';
import 'package:aide_client/views/widgets/custom_button.dart';
import 'package:aide_client/views/widgets/custom_textfield.dart';
import 'package:aide_client/views/widgets/logo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserWrapper extends StatefulWidget {
  const UserWrapper({super.key});

  @override
  State<UserWrapper> createState() => _UserWrapperState();
}

class _UserWrapperState extends State<UserWrapper> {
  late Future<void> _fetchConversationsFuture;

  @override
  void initState() {
    super.initState();
    _fetchConversationsFuture =
        Provider.of<UserSidebarProvider>(
          context,
          listen: false,
        ).fetchConversations();
  }

  @override
  Widget build(BuildContext context) {
    final userSidebarProvider = Provider.of<UserSidebarProvider>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Row(
        children: [
          Container(
            width: 300,
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border(
                right: BorderSide(color: Colors.grey.shade900, width: 2),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 50,
                  child: TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.grey.shade900,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.add, color: Colors.white),
                        SizedBox(width: 10),
                        Text(
                          "New Conversation",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Conversations",
                  style: TextStyle(color: Colors.grey, fontSize: 15),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: FutureBuilder(
                    future: _fetchConversationsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CupertinoActivityIndicator(
                            color: Colors.white,
                            radius: 12,
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            "Error: ${snapshot.error}",
                            style: const TextStyle(color: Colors.red),
                          ),
                        );
                      } else {
                        final conversations = userSidebarProvider.conversations;
                        if (conversations.isEmpty) {
                          return const Center(
                            child: Text(
                              "No conversations found",
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        }
                        return ListView.builder(
                          itemCount: conversations.length,
                          itemBuilder: (context, index) {
                            final conversation = conversations[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: ListTile(
                                leading: const Icon(
                                  Icons.chat,
                                  color: Colors.white,
                                ),
                                title: Text(
                                  conversation.title,
                                  style: const TextStyle(color: Colors.white),
                                ),
                                onTap: () {
                                  userSidebarProvider.currentConversation =
                                      conversation;
                                },
                              ),
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
                Center(
                  child: CustomButton(
                    onPressed: () async {
                      await userSidebarProvider.logout(context);
                    },
                    text: "Log out",
                    width: 200,
                  ),
                ),
              ],
            ),
          ),

          // main content area
          Expanded(
            child: UserChatPage(),
          ), // main content area
        ],
      ),
    );
  }
}

