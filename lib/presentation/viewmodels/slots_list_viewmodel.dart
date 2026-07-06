import 'package:flutter/material.dart';
import '../../data/models/slot_model.dart';
import '../../data/services/mock_api_service.dart';

enum SlotsListStatus { initial, loading, success, empty, error }

class SlotsListViewModel extends ChangeNotifier {
  final MockApiService _apiService;

  SlotsListViewModel({required MockApiService apiService}) : _apiService = apiService;

  List<SlotModel> _slots = [];
  List<SlotModel> get slots => _slots;

  SlotsListStatus _status = SlotsListStatus.initial;
  SlotsListStatus get status => _status;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  Future<void> loadSlots() async {
    _status = SlotsListStatus.loading;
    notifyListeners();

    try {
      final fetchedSlots = await _apiService.fetchSlots();
      _slots = fetchedSlots;
      
      if (_slots.isEmpty) {
        _status = SlotsListStatus.empty;
      } else {
        _status = SlotsListStatus.success;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _status = SlotsListStatus.error;
    }
    notifyListeners();
  }
}