import 'package:flutter/cupertino.dart';

class NavigationProvider extends ChangeNotifier{
  int _index = 0;

  int get index => _index;

  void setIndex(index){
    _index = index;
    notifyListeners();
  }
}