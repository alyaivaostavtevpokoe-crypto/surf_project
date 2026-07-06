import 'package:flutter/material.dart';
import 'data/services/mock_api_service.dart';
import 'presentation/viewmodels/slots_list_viewmodel.dart';
import 'presentation/ui/slots_list/slots_list_screen.dart';

void main() {
  runApp(const SurfProjectApp());
}

class SurfProjectApp extends StatelessWidget {
  const SurfProjectApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Инициализируем синглтон сервиса и ViewModel на самом верхнем уровне приложения
    final mockApiService = MockApiService();
    final slotsViewModel = SlotsListViewModel(apiService: mockApiService);

    return MaterialApp(
      title: 'Картинг-Центр Surf',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Colors.grey[50],
        useMaterial3: true,
      ),
      // Передаем готовую ViewModel в конструктор экрана расписания
      home: SlotsListScreen(viewModel: slotsViewModel),
    );
  }
}