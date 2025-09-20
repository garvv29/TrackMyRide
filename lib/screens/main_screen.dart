import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'complaint_screen.dart';
import '../widgets/custom_drawer.dart';
import '../l10n/app_localizations.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const SearchScreen(),
    const ComplaintScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      drawer: const CustomDrawer(),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: AppLocalizations.of(context)?.home ?? 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: AppLocalizations.of(context)?.search ?? 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report_problem),
            label: AppLocalizations.of(context)?.complaint ?? 'Complaint',
          ),
        ],
      ),
    );
  }

  String _getAppBarTitle() {
    switch (_selectedIndex) {
      case 0:
        return AppLocalizations.of(context)?.trackMyRide ?? 'Track My Ride';
      case 1:
        return AppLocalizations.of(context)?.searchBuses ?? 'Search Buses';
      case 2:
        return AppLocalizations.of(context)?.report ?? 'Report';
      default:
        return AppLocalizations.of(context)?.trackMyBus ?? 'Track My Bus';
    }
  }
}