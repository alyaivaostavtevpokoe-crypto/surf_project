import '../models/master_model.dart';
import '../models/slot_model.dart';

class MockApiService {
  // Симуляция получения списка доступных заездов (слотов) с бэкенда
  Future<List<SlotModel>> fetchSlots() async {
    // Искусственная задержка сети 800 миллисекунд
    await Future.delayed(const Duration(milliseconds: 800));
    
    final now = DateTime.now();

    final master1 = MasterModel(
      id: 'mstr_8801',
      firstName: 'Алексей',
      lastName: 'Петров',
      qualification: 'КМС по автоспорту',
      rating: 4.9,
    );

    final master2 = MasterModel(
      id: 'mstr_8802',
      firstName: 'Иван',
      lastName: 'Сидоров',
      qualification: 'Профессиональный инструктор',
      rating: 4.7,
    );

    return [
      // 1. Обычный слот со свободными местами на сегодня
      SlotModel(
        id: 'slot_01',
        startTime: DateTime(now.year, now.month, now.day, 12, 0),
        endTime: DateTime(now.year, now.month, now.day, 12, 45),
        master: master1,
        capacityTotal: 8,
        remainingSeats: 5,
        priceRub: 2500.0,
        isCancelledByWorkshop: false,
        isEquipmentRequired: true,
      ),
      // 2. Слот без свободных мест на завтра (для проверки Full State)
      SlotModel(
        id: 'slot_02',
        startTime: DateTime(now.year, now.month, now.day + 1, 15, 0),
        endTime: DateTime(now.year, now.month, now.day + 1, 15, 45),
        master: master2,
        capacityTotal: 8,
        remainingSeats: 0,
        priceRub: 2700.0,
        isCancelledByWorkshop: false,
        isEquipmentRequired: false,
      ),
      // 3. ОБЯЗАТЕЛЬНО: Слот, отмененный самой мастерской (для проверки Фичи 3)
      SlotModel(
        id: 'slot_03',
        startTime: DateTime(now.year, now.month, now.day + 2, 18, 0),
        endTime: DateTime(now.year, now.month, now.day + 2, 18, 45),
        master: master1,
        capacityTotal: 6,
        remainingSeats: 2,
        priceRub: 3000.0,
        isCancelledByWorkshop: true, 
        cancellationReason: "Технические работы на покрытии трека (замена отбойников)",
        isEquipmentRequired: true,
      ),
      // 4. Обычный слот со свободными местами под конец недели
      SlotModel(
        id: 'slot_04',
        startTime: DateTime(now.year, now.month, now.day + 5, 10, 0),
        endTime: DateTime(now.year, now.month, now.day + 5, 10, 45),
        master: master2,
        capacityTotal: 10,
        remainingSeats: 9,
        priceRub: 2200.0,
        isCancelledByWorkshop: false,
        isEquipmentRequired: true,
      ),
    ];
  }

  // Симуляция отправки запроса на бронирование в Картинг-Центр
  Future<bool> bookSlot({
    required String slotId,
    required int seatsCount,
    required bool rentalRequired,
  }) async {
    // Искусственная задержка сети 1000 миллисекунд
    await Future.delayed(const Duration(milliseconds: 1000));
    
    // Имитация бизнес-валидации бэкенда:
    // Если пользователь пытается заказать больше 4 мест за раз, бэкенд возвращает ошибку
    if (seatsCount > 4) {
      throw Exception("Превышен лимит группового бронирования для одного пользователя (макс. 4 места).");
    }
    
    return true; // Успешный ответ от сервера
  }
}