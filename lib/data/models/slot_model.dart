import 'master_model.dart';

class SlotModel {
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final MasterModel master;
  final int capacityTotal;
  final int remainingSeats;
  final double priceRub;
  final bool isCancelledByWorkshop;
  final String? cancellationReason; // Причина отмены заезда
  final bool isEquipmentRequired;

  SlotModel({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.master,
    required this.capacityTotal,
    required this.remainingSeats,
    required this.priceRub,
    required this.isCancelledByWorkshop,
    this.cancellationReason,
    required this.isEquipmentRequired,
  });

  factory SlotModel.fromJson(Map<String, dynamic> json) {
    return SlotModel(
      id: json['id'] as String,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      master: MasterModel.fromJson(json['master'] as Map<String, dynamic>),
      capacityTotal: json['capacity_total'] as int,
      remainingSeats: json['remaining_seats'] as int,
      priceRub: (json['price_rub'] as num).toDouble(),
      isCancelledByWorkshop: json['is_cancelled_by_workshop'] as bool,
      cancellationReason: json['cancellation_reason'] as String?,
      isEquipmentRequired: json['is_equipment_required'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'master': master.toJson(),
      'capacity_total': capacityTotal,
      'remaining_seats': remainingSeats,
      'price_rub': priceRub,
      'is_cancelled_by_workshop': isCancelledByWorkshop,
      'cancellation_reason': cancellationReason,
      'is_equipment_required': isEquipmentRequired,
    };
  }
}