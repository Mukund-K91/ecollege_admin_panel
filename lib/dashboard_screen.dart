import 'package:ecollege_admin_panel/announcement.dart';
import 'package:ecollege_admin_panel/dashboard_home.dart';
import 'package:ecollege_admin_panel/login_screen.dart';
import 'package:ecollege_admin_panel/slider_img.dart';
import 'package:ecollege_admin_panel/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'faculty_management.dart';
import 'firebase_options.dart';
import 'student_management.dart';

enum SampleItem { itemOne, itemTwo, itemThree }

class DashboardScreen extends StatefulWidget {
  final userType;
  final userName;

  const DashboardScreen({Key? key,this.userType, this.userName,})
      : super(key: key);

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
  SampleItem? selectedItem;

  late final List<Widget> _screens;

  void initState() {
    super.initState();
    _screens = [
      Home(),
      AddStudents(userType: widget.userType),
      StudentList(userType: widget.userType,),
      AddFaculty(userType: widget.userType,),
      FacultyList(userType: widget.userType,),
      EventManagement(),
      SliderPage()
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
            padding: const EdgeInsets.all(10),
            child: PopupMenuButton<String>(
              position: PopupMenuPosition.under,
              child: Row(
                children: [
                  widget.userType == "Super Admin"
                      ? Icon(FontAwesomeIcons.userTie, color: Color(0xff002233))
                      : Icon(
                          Icons.person,
                          color: Color(0xff002233),
                        ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    '${widget.userType}',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xff4b8bbf),
                        fontSize: 15),
                  ),
                ],
              ),
              onSelected: (value) {
                print('Selected: $value');
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: Text(
                    'User: ${widget.userName}',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                PopupMenuItem(
                  child: TextButton.icon(
                    onPressed: () async {
                      var sharedPref = await SharedPreferences.getInstance();
                      sharedPref.remove(SplashScreenState.KEYLOGIN);
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginScreen(),
                          ));
                    },
                    icon: Icon(FontAwesomeIcons.signOut),
                    label: Text("Log Out"),
                  ),
                ),
              ],
            ),
          ),
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
          MenuItem(
            title: ' Sliders',
            index: 6,
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
