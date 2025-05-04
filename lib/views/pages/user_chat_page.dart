import 'package:aide_client/models/message_model.dart';
import 'package:aide_client/providers/chat_provider.dart';
import 'package:aide_client/providers/user_sidebar_provider.dart';
import 'package:aide_client/views/widgets/custom_textfield.dart';
import 'package:aide_client/views/widgets/logo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:markdown_widget/widget/all.dart';
import 'package:provider/provider.dart';

class UserChatPage extends StatefulWidget {
  const UserChatPage({super.key});

  @override
  State<UserChatPage> createState() => _UserChatPageState();
}

class _UserChatPageState extends State<UserChatPage> {
  String? _lastConversationId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final sidebarProvider = Provider.of<UserSidebarProvider>(context);
    final chatProvider = Provider.of<UserChatProvider>(context, listen: false);

    final conversationId = sidebarProvider.currentConversationId;

    if (conversationId != null && conversationId != _lastConversationId) {
      _lastConversationId = conversationId;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        chatProvider.fetchMessages(conversationId, context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final sidebarProvider = Provider.of<UserSidebarProvider>(context);
    final chatProvider = Provider.of<UserChatProvider>(context);

    final conversationId = sidebarProvider.currentConversationId;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Logo(),
        toolbarHeight: 70,
      ),
      body:
          conversationId == null
              ? const Center(
                child: Text(
                  "Select a conversation to start chatting",
                  style: TextStyle(color: Colors.white),
                ),
              )
              : Column(
                children: [
                  Expanded(
                    child:
                        chatProvider.isLoading
                            ? const Center(
                              child: CupertinoActivityIndicator(
                                color: Colors.grey,
                                radius: 15,
                              ),
                            )
                            : chatProvider.messages.isEmpty
                            ? Center(
                              child: Text(
                                "No messages yet",
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 20,
                                ),
                              ),
                            )
                            : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              reverse: true,
                              itemCount: chatProvider.messages.length,
                              itemBuilder: (context, index) {
                                final message =
                                    chatProvider.messages[chatProvider
                                            .messages
                                            .length -
                                        1 -
                                        index];
                                final isUser = message.role == 'user';

                                return Align(
                                  alignment:
                                      isUser
                                          ? Alignment.centerRight
                                          : Alignment.centerLeft,
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 6,
                                    ),
                                    padding: const EdgeInsets.all(12),
                                    constraints: BoxConstraints(
                                      maxWidth:
                                          600,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          isUser
                                              ? Colors.deepOrange
                                              : Colors.grey.shade200,
                                      borderRadius: BorderRadius.only(
                                        topLeft: const Radius.circular(16),
                                        topRight: const Radius.circular(16),
                                        bottomLeft: Radius.circular(
                                          isUser ? 16 : 0,
                                        ),
                                        bottomRight: Radius.circular(
                                          isUser ? 0 : 16,
                                        ),
                                      ),
                                    ),
                                    child:
                                        message.metadata != null &&
                                                message.metadata!['loading'] ==
                                                    true
                                            ? const CupertinoActivityIndicator(
                                              color: Colors.black,
                                              radius: 10,
                                            )
                                            : MarkdownWidget(
                                              physics:
                                                  NeverScrollableScrollPhysics(),
                                              shrinkWrap: true,
                                              data: message.content,
                                            ),
                                  ),
                                );
                              },
                            ),
                  ),
                  Container(
                    color: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomTextfield(
                            height: 150,
                            width: 500,
                            expandable: true,
                            controller: chatProvider.messageController,
                            hintText: "Type your message here",
                          ),
                          const SizedBox(width: 10),
                          IconButton(
                            onPressed: () async {
                              if (conversationId != null &&
                                  chatProvider.messageController.text
                                      .trim()
                                      .isNotEmpty) {
                                await chatProvider.sendMessage(
                                  context,
                                  conversationId,
                                );
                              }
                            },
                            icon: const Icon(Icons.send, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
    );
  }
}
