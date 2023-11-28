import 'package:flutter/material.dart';

class AppBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabTapped;

  const AppBottomNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onTabTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, -1),
            blurRadius: 5,
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTabTapped,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontFamily: 'Montserrat', // Use a custom font for selected labels
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.normal,
          fontFamily: 'Montserrat', // Use a custom font for unselected labels
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.event, size: 28), // Adjust icon size
            label: 'Activités',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add, size: 28), // Adjust icon size
            label: 'Ajout',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, size: 28), // Adjust icon size
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}