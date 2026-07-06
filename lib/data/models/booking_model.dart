import 'slot_model.dart';

class BookingModel {
  final String id;
  final String clientId;
  final SlotModel slot;
  final bool includeEquipmentRental;
  final String status;
  final DateTime createdAt;

  BookingModel({
    required this.id,
    required this.clientId,
    required this.slot,
    required this.includeEquipmentRental,
    required this.status,
    required this.createdAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as String,
      clientId: json['client_id'] as String,
      slot: SlotModel.fromJson(json['slot'] as Map<String, dynamic>),
      includeEquipmentRental: json['include_equipment_rental'] as bool,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client_id': clientId,
      'slot': slot.toJson(),
      'include_equipment_rental': includeEquipmentRental,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}