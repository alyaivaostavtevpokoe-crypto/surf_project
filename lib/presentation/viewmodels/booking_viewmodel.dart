import 'package:flutter/material.dart';
import '../../data/services/mock_api_service.dart';
import '../../data/models/slot_model.dart';

enum BookingStatus { initial, submitting, success, failure }

class BookingViewModel extends ChangeNotifier {
  final MockApiService _apiService;
  final SlotModel slot;

  // Фиксированная стоимость аренды инвентаря за одного человека
  static const double equipmentRentalCost = 500.0;

  BookingViewModel({
    required MockApiService apiService,
    required this.slot,
  }) : _apiService = apiService {
    // Если места есть, минимально выбираем 1 место
    _selectedSeats = slot.remainingSeats > 0 ? 1 : 0;
    
    // БАГ ИСПРАВЛЕН: Если слот требует обязательный инвентарь, 
    // инициализируем флаг как true принудительно
    _isEquipmentRentalIncluded = slot.isEquipmentRequired;
  }

  int _selectedSeats = 0;
  int get selectedSeats => _selectedSeats;

  bool _isEquipmentRentalIncluded = false;
  bool get isEquipmentRentalIncluded => _isEquipmentRentalIncluded;

  BookingStatus _status = BookingStatus.initial;
  BookingStatus get status => _status;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  // БАГ ИСПРАВЛЕН: Рассчитываем итоговую цену динамически во ViewModel с учетом проката
  double get totalCost {
    final baseCost = slot.priceRub * _selectedSeats;
    final rentalCost = _isEquipmentRentalIncluded ? (equipmentRentalCost * _selectedSeats) : 0.0;
    return baseCost + rentalCost;
  }

  void incrementSeats() {
    if (_status == BookingStatus.submitting) return;
    if (_selectedSeats < slot.remainingSeats) {
      _selectedSeats++;
      notifyListeners();
    }
  }

  void decrementSeats() {
    if (_status == BookingStatus.submitting) return;
    if (_selectedSeats > 1) {
      _selectedSeats--;
      notifyListeners();
    }
  }

  void toggleEquipmentRental(bool value) {
    if (_status == BookingStatus.submitting) return;
    
    // БАГ ИСПРАВЛЕН: Запрещаем отключать инвентарь, если он строго требуется для заезда
    if (slot.isEquipmentRequired) return;
    
    _isEquipmentRentalIncluded = value;
    notifyListeners();
  }

  Future<void> sendBooking() async {
    // БАГ ИСПРАВЛЕН: Защита от Race Condition / Double Submit на уровне бизнес-логики.
    // Если запрос уже отправляется, полностью игнорируем повторные вызовы метода.
    if (_status == BookingStatus.submitting) return;
    if (_selectedSeats <= 0) return;

    _status = BookingStatus.submitting;
    notifyListeners();

    try {
      final success = await _apiService.bookSlot(
        slotId: slot.id,
        seatsCount: _selectedSeats,
        rentalRequired: _isEquipmentRentalIncluded,
      );
      
      if (success) {
        _status = BookingStatus.success;
      } else {
        _errorMessage = "Не удалось создать бронирование. Попробуйте позже.";
        _status = BookingStatus.failure;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll("Exception: ", "");
      _status = BookingStatus.failure;
    }
    notifyListeners();
  }
}