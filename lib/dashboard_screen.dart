import 'package:ecollege_admin_panel/announcement.dart';
import 'package:ecollege_admin_panel/dashboard_home.dart';
import 'package:ecollege_admin_panel/demo.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'faculty_management.dart';
import 'firebase_options.dart';
import 'student_management.dart';

class DashboardScreen extends StatefulWidget {
  final userType;

  const DashboardScreen({Key? key, required this.userType}) : super(key: key);

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

  late final List<Widget> _screens;

  void initState() {
    super.initState();
    _screens = [
      Home(),
      AddStudents(userType: widget.userType),
      StudentList(),
      AddFaculty(),
      FacultyList(),
      EventManagement(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4.0),
            child: Container(
              color: Color(0xff002233),
              height: 4,
            )),
        title: Image(
          image: AssetImage('assets/Images/eCollege.png'),
          height: 200,
          width: 200,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
                onPressed: () {},
                icon: Icon(
                  FontAwesomeIcons.powerOff,
                  color: Color(0xff002233),
                )),
          )
        ],
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
      color: Color(0xff002233),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MenuItem(
            icon: Icon(
              FontAwesomeIcons.home,
              color: Colors.white,
            ),
            title: ' Dashboard',
            index: 0,
            selectedIndex: selectedIndex,
            onMenuItemSelected: onMenuItemSelected,
          ),
          ExpansionTile(
            title: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    FontAwesomeIcons.graduationCap,
                    color: Colors.white,
                  ),
                ),
                Text(
                  " Students",
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
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
          ExpansionTile(
            title: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    FontAwesomeIcons.user,
                    color: Colors.white,
                  ),
                ),
                Text(
                  " Faculty",
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            children: [
              MenuItem(
                title: 'Add Faculty',
                index: 3,
                selectedIndex: selectedIndex,
                onMenuItemSelected: onMenuItemSelected,
              ),
              MenuItem(
                title: 'Faculty Details',
                index: 4,
                selectedIndex: selectedIndex,
                onMenuItemSelected: onMenuItemSelected,
              ),
            ],
          ),
          MenuItem(
            title: ' Announcement',
            index: 5,
            selectedIndex: selectedIndex,
            onMenuItemSelected: onMenuItemSelected,
            icon: Icon(
              FontAwesomeIcons.bullhorn,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class MenuItem extends StatelessWidget {
  final String title;
  final Icon? icon;
  final int index;
  final int selectedIndex;
  final Function(int) onMenuItemSelected;

  MenuItem({
    required this.title,
    this.icon,
    required this.index,
    required this.selectedIndex,
    required this.onMenuItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: icon,
          ),
          Text(
            title,
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
      onTap: () {
        onMenuItemSelected(index);
      },
    );
  }
}
