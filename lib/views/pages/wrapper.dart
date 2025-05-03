import 'package:aide_client/providers/navigation_provider.dart';
import 'package:aide_client/views/pages/create_agent_page.dart';
import 'package:aide_client/views/pages/homepage.dart';
import 'package:aide_client/views/pages/train_agent_page.dart';
import 'package:aide_client/views/widgets/logo.dart';
import 'package:aide_client/views/widgets/top_navigation_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WrapperPage extends StatelessWidget {
  const WrapperPage({super.key});

  @override
  Widget build(BuildContext context) {
    int currentIndex = context.watch<NavigationProvider>().index;

    return Scaffold(
      backgroundColor: Colors.black,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // logo
              Logo(),
              // seperator
              Divider(color: Colors.grey.shade800, thickness: .8),

              // top navigation
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                spacing: 5,
                children: [
                  // home
                  TopNavigationButton(
                    onTap: () {
                      context.read<NavigationProvider>().setIndex(0);
                    },
                    text: "Home",
                    icon: Icons.home_outlined,
                    active: currentIndex==0,
                  ),
                  // create agent
                  TopNavigationButton(
                    onTap: () {
                      context.read<NavigationProvider>().setIndex(1);
                    },
                    text: "Create an agent",
                    icon: Icons.add_circle_outline,
                    active: currentIndex==1,
                  ),

                  // train agent
                  TopNavigationButton(
                    onTap: () {
                      context.read<NavigationProvider>().setIndex(2);
                    },
                    text: "Train an agent",
                    icon: Icons.model_training,
                    active: currentIndex==2,
                  ),
                ],
              ),

              const SizedBox(height: 20),
              // content
              currentIndex == 0
                  ? Expanded(child: HomePage())
                  : currentIndex == 1
                  ? Expanded(child: CreateAgentPage())
                  : Expanded(child: TrainAgentPage()),
            ],
          ),
        ),
      ),
    );
  }
}
