import 'package:adios_unite/enum/view_state.dart';
import 'package:flutter/material.dart';

class ImageUploadProvider with ChangeNotifier{

  ViewState _viewState = ViewState.IDLE;
  ViewState get getViewState => _viewState;

  void setToLoading() {
    _viewState = ViewState.LOADING;
    notifyListeners();
  }
  
  void setToIdle() {
    _viewState = ViewState.IDLE;
    notifyListeners();
  }

}