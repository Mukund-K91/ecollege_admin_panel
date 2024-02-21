import 'package:ecollege_admin_panel/dashboard_home.dart';
import 'package:ecollege_admin_panel/demo.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'faculty_management.dart';
import 'firebase_options.dart';
import 'student_management.dart';

class DashboardScreen extends StatefulWidget {
  void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    //  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,overlays: SystemUiOverlay.values);
  }
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    Home(),
    AddStudents(),
    StudentList(),
    StudentListScreen(),
    LogoutScreen()
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
            title: 'Dashboard',
            index: 0,
            selectedIndex: selectedIndex,
            onMenuItemSelected: onMenuItemSelected,
          ),
          ExpansionTile(title: Text("Student Management"),
            children: [
              MenuItem(
                title: 'Add Student',
                index: 1,
                selectedIndex: selectedIndex,
                onMenuItemSelected: onMenuItemSelected,
              ),
              MenuItem(
                title: 'Student Details',
                index: 2,
                selectedIndex: selectedIndex,
                onMenuItemSelected: onMenuItemSelected,
              ),
            ],

          ),
          MenuItem(
            title: 'Faculty Management',
            index: 3,
            selectedIndex: selectedIndex,
            onMenuItemSelected: onMenuItemSelected,
          ),
          MenuItem(
            title: 'Settings',
            index: 4,
            selectedIndex: selectedIndex,
            onMenuItemSelected: onMenuItemSelected,
          ),
          MenuItem(
            title: 'Logout',
            index: 5,
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
