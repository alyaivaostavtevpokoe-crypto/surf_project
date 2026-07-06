import 'package:flutter/material.dart';
import '../../viewmodels/slots_list_viewmodel.dart';
import '../booking_details/booking_bottom_sheet.dart';
import 'widgets/slot_card.dart';

class SlotsListScreen extends StatefulWidget {
  final SlotsListViewModel viewModel;

  const SlotsListScreen({Key? key, required this.viewModel}) : super(key: key);

  @override
  State<SlotsListScreen> createState() => _SlotsListScreenState();
}

class _SlotsListScreenState extends State<SlotsListScreen> {
  @override
  void initState() {
    super.initState();
    // Автоматическая загрузка данных при первой отрисовке экрана
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.viewModel.loadSlots();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Расписание заездов"),
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Обновить расписание",
            onPressed: () => widget.viewModel.loadSlots(),
          )
        ],
      ),
      body: AnimatedBuilder(
        animation: widget.viewModel,
        builder: (context, _) {
          switch (widget.viewModel.status) {
            case SlotsListStatus.initial:
            case SlotsListStatus.loading:
              return const Center(
                child: CircularProgressIndicator(),
              );
            
            case SlotsListStatus.empty:
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        "Пока нет доступных занятий",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => widget.viewModel.loadSlots(),
                        child: const Text("Обновить"),
                      )
                    ],
                  ),
                ),
              );

            case SlotsListStatus.error:
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        "Ошибка загрузки данных:\n${widget.viewModel.errorMessage}",
                        style: const TextStyle(fontSize: 16, color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => widget.viewModel.loadSlots(),
                        child: const Text("Повторить попытку"),
                      )
                    ],
                  ),
                ),
              );

            case SlotsListStatus.success:
              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: widget.viewModel.slots.length,
                itemBuilder: (context, index) {
                  final slot = widget.viewModel.slots[index];
                  
                  return InkWell(
                    // Если заезд отменен мастерской, клик заблокирован
                    onTap: slot.isCancelledByWorkshop 
                        ? null 
                        : () => BookingBottomSheet.show(context, slot),
                    child: SlotCard(slot: slot),
                  );
                },
              );
          }
        },
      ),
    );
  }
}