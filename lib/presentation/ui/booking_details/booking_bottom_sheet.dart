import 'package:flutter/material.dart';
import '../../../data/models/slot_model.dart';
import '../../../data/services/mock_api_service.dart';
import '../../viewmodels/booking_viewmodel.dart';
import 'booking_success_screen.dart';

class BookingBottomSheet extends StatefulWidget {
  final SlotModel slot;

  const BookingBottomSheet({Key? key, required this.slot}) : super(key: key);

  static void show(BuildContext context, SlotModel slot) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => BookingBottomSheet(slot: slot),
    );
  }

  @override
  State<BookingBottomSheet> createState() => _BookingBottomSheetState();
}

class _BookingBottomSheetState extends State<BookingBottomSheet> {
  late BookingViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    // Инициализируем ViewModel, передавая текущий слот
    _viewModel = BookingViewModel(apiService: MockApiService(), slot: widget.slot);
    _viewModel.addListener(_onViewModelUpdate);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelUpdate);
    _viewModel.dispose();
    super.dispose();
  }

  void _onViewModelUpdate() {
    if (_viewModel.status == BookingStatus.success) {
      Navigator.of(context).pop(); // Закрываем Bottom Sheet
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const BookingSuccessScreen()),
      );
    } else if (_viewModel.status == BookingStatus.failure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_viewModel.errorMessage), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final startTimeStr = "${widget.slot.startTime.hour.toString().padLeft(2, '0')}:${widget.slot.startTime.minute.toString().padLeft(2, '0')}";

    return AnimatedBuilder(
      animation: _viewModel,
      builder: (context, _) {
        // ИСПРАВЛЕНО: Расчет стоимости теперь запрашивается из ViewModel
        final totalCost = _viewModel.totalCost;
        final isSubmitting = _viewModel.status == BookingStatus.submitting;

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              Text("Оформление бронирования", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text("Заезд сегодня в $startTimeStr с тренером ${widget.slot.master.fullName}", style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 20),
              
              // Счетчик мест
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Количество мест", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  Row(
                    children: [
                      IconButton(
                        onPressed: isSubmitting ? null : _viewModel.decrementSeats,
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      Text("${_viewModel.selectedSeats}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      IconButton(
                        onPressed: isSubmitting ? null : _viewModel.incrementSeats,
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                ],
              ),
              
              // Чекбокс аренды инвентаря
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text("Нужна аренда инвентаря", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                subtitle: Text(
                  widget.slot.isEquipmentRequired 
                    ? "Экипировка обязательна для этого заезда (+500 ₽/чел)" 
                    : "Шлем, костюм и перчатки (+500 ₽/чел)", 
                  style: const TextStyle(fontSize: 12)
                ),
                value: _viewModel.isEquipmentRentalIncluded,
                // ИСПРАВЛЕНО: Свитчер блокируется (передается null), если инвентарь обязателен по регламенту слота
                onChanged: (isSubmitting || widget.slot.isEquipmentRequired) 
                    ? null 
                    : _viewModel.toggleEquipmentRental,
              ),
              
              const Divider(height: 32),
              
              // Итого и Кнопка
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Итого к оплате:", style: TextStyle(fontSize: 16, color: Colors.grey)),
                  Text("${totalCost.toStringAsFixed(0)} ₽", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green)),
                ],
              ),
              const SizedBox(height: 20),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: (widget.slot.remainingSeats == 0 || isSubmitting) ? null : () => _viewModel.sendBooking(),
                  child: isSubmitting
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(widget.slot.remainingSeats == 0 ? "Мест нет" : "Записаться"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}