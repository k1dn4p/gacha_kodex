import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/ticket_provider.dart';
import 'pages/main_page.dart';
import 'pages/gacha_page.dart';
import 'pages/result_page.dart';
import 'pages/setting_page.dart';
import 'pages/status_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TicketProvider()),
      ],
      child: MaterialApp(
        title: 'Gacha Kodex',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        routes: {
          '/': (context) => const MainPage(),
          '/gacha': (context) => const GachaPage(),
          '/result': (context) => const ResultPage(),
          '/status': (context) => const StatusPage(),
          '/settings': (context) => const SettingPage(),
        },
      ),
    );
  }
}
