
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

const Color metroBlue = Color(0xFF005CA9);
const Color darkBlue = Color(0xFF003B70);

class LinesScreen extends StatefulWidget {
  const LinesScreen({super.key});

  @override
  State<LinesScreen> createState() => _LinesScreenState();
}

class _LinesScreenState extends State<LinesScreen> {
  int selectedIndex = 0;

  final List<String> pages = [
    'Monitoramento de Linhas',
    'Estações',
    'Alertas',
    'Configurações',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'FLUXO',
          style: TextStyle(
            color: darkBlue,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Center(
        child: Text(
          pages[selectedIndex],
          style: const TextStyle(
            color: darkBlue,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: metroBlue,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.trainFront),
            label: 'Linhas',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.mapPin),
            label: 'Estações',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.bell),
            label: 'Alertas',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.settings),
            label: 'Configurações',
          ),
        ],
      ),
    );
  }
}
