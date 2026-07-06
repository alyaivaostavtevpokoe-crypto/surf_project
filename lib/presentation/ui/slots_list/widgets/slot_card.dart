import 'package:flutter/material.dart';
import '../../../../data/models/slot_model.dart';

class SlotCard extends StatelessWidget {
  final SlotModel slot;

  const SlotCard({Key? key, required this.slot}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final startTimeStr = "${slot.startTime.hour.toString().padLeft(2, '0')}:${slot.startTime.minute.toString().padLeft(2, '0')}";
    final endTimeStr = "${slot.endTime.hour.toString().padLeft(2, '0')}:${slot.endTime.minute.toString().padLeft(2, '0')}";
    final dateStr = "${slot.startTime.day.toString().padLeft(2, '0')}.${slot.startTime.month.toString().padLeft(2, '0')}.${slot.startTime.year}";

    final isFull = slot.remainingSeats == 0;
    final isCancelled = slot.isCancelledByWorkshop;

    final cardContent = Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Обернуто в Expanded, чтобы дата не конфликтовала с длинным бейджем
              Expanded(
                child: Text(
                  "$dateStr | $startTimeStr - $endTimeStr",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isCancelled ? Colors.grey : Colors.blueGrey,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: 8),
              if (isCancelled)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    "ОТМЕНЕНО",
                    style: TextStyle(color: Colors.black54, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                )
              else
                Text(
                  "${slot.priceRub.toStringAsFixed(0)} ₽",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green),
                ),
            ],
          ),
          const Divider(height: 20),
          
          // ИСПРАВЛЕНО: Защита названия заезда от переполнения экрана
          Text(
            "Заезд Картинг-Центра со сверхдлинным тренировочным названием для MVP",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: isCancelled ? Colors.grey : Colors.black87,
                  decoration: isCancelled ? TextDecoration.lineThrough : null,
                ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1, // Ограничиваем одной строкой с троеточием
          ),
          const SizedBox(height: 4),
          
          // ИСПРАВЛЕНО: Защита имени инструктора от переполнения экрана
          Text(
            "Инструктор: ${slot.master.fullName} ${isCancelled ? '' : '(★ ${slot.master.rating})'}",
            style: const TextStyle(color: Colors.grey),
            overflow: TextOverflow.ellipsis,
            maxLines: 1, // Текст аккуратно усекается, если имя слишком длинное
          ),
          
          if (isCancelled && slot.cancellationReason != null) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.red.shade100),
              ),
              child: Text(
                "Причина: ${slot.cancellationReason}",
                style: TextStyle(color: Colors.red.shade900, fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ),
          ],

          const SizedBox(height: 12),
          if (!isCancelled)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // ИСПРАВЛЕНО: Оборачиваем левую часть в Flexible, чтобы длинный статус мест справа не вылетал за экран
                Flexible(
                  child: Row(
                    children: [
                      Icon(
                        slot.isEquipmentRequired ? Icons.handyman : Icons.no_flash,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          slot.isEquipmentRequired ? "Нужен инвентарь" : "Экипировка своя",
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  isFull ? "Мест нет" : "Осталось мест: ${slot.remainingSeats}/${slot.capacityTotal}",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isFull ? Colors.red : Colors.black87,
                  ),
                ),
              ],
            ),
        ],
      ),
    );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: isCancelled ? 0 : 2,
      color: isCancelled ? Colors.grey.shade100 : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isCancelled 
            ? BorderSide(color: Colors.grey.shade300, width: 1) 
            : BorderSide.none,
      ),
      child: isCancelled 
          ? Opacity(opacity: 0.65, child: cardContent) 
          : cardContent,
    );
  }
}