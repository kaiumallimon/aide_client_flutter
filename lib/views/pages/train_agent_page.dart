import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TrainAgentPage extends StatefulWidget {
  const TrainAgentPage({super.key});

  @override
  State<TrainAgentPage> createState() => TrainAgentPageState();
}

class TrainAgentPageState extends State<TrainAgentPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Train agent page'),
      ),
    );
  }
}