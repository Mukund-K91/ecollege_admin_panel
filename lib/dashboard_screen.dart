
import 'package:flutter/material.dart';
import 'add_faculty.dart';
import 'admission_form.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    AdmissionForm(),
    AddFaculty(),
    SettingsScreen(),
    LogoutScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
      ),
      body: Row(
        children: [
          SideMenu(
            selectedIndex: _selectedIndex,
            onMenuItemSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
          VerticalDivider(),
          Expanded(
            child: _screens[_selectedIndex],
          ),
        ],
      ),
    );
  }
}

class SideMenu extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onMenuItemSelected;

  SideMenu({
    required this.selectedIndex,
    required this.onMenuItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: Colors.blue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(
            color: Colors.white,
          ),
          MenuItem(
            title: 'Student Management',
            index: 0,
            selectedIndex: selectedIndex,
            onMenuItemSelected: onMenuItemSelected,
          ),
          MenuItem(
            title: 'Faculty Management',
            index: 1,
            selectedIndex: selectedIndex,
            onMenuItemSelected: onMenuItemSelected,
          ),
          MenuItem(
            title: 'Settings',
            index: 2,
            selectedIndex: selectedIndex,
            onMenuItemSelected: onMenuItemSelected,
          ),
          MenuItem(
            title: 'Logout',
            index: 3,
            selectedIndex: selectedIndex,
            onMenuItemSelected: onMenuItemSelected,
          ),
        ],
      ),
    );
  }
}

class MenuItem extends StatelessWidget {
  final String title;
  final int index;
  final int selectedIndex;
  final Function(int) onMenuItemSelected;

  MenuItem({
    required this.title,
    required this.index,
    required this.selectedIndex,
    required this.onMenuItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          color: index == selectedIndex ? Colors.white : Colors.white54,
        ),
      ),
      onTap: () {
        onMenuItemSelected(index);
      },
    );
  }
}

class UserManagementScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'User Management Screen Con',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}

class DataAnalyticsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Data Analytics Screen',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Settings Screen',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}

class LogoutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Logout Screen',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}
