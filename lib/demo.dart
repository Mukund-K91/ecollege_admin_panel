import 'package:flutter/material.dart';


class Demo extends StatefulWidget {
  @override
  _DemoState createState() => _DemoState();
}

class _DemoState extends State<Demo> {
  int _selectedMainMenuItemIndex = 0;
  int _selectedSubMenuItemIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
      ),
      body: Row(
        children: [
          // Side Menu
          Container(
            width: 200,
            color: Colors.grey[200],
            child: ListView.builder(
              itemCount: mainMenuItems.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(mainMenuItems[index]),
                  selected: _selectedMainMenuItemIndex == index,
                  onTap: () {
                    setState(() {
                      _selectedMainMenuItemIndex = index;
                      _selectedSubMenuItemIndex = 0; // Reset sub-menu selection
                    });
                  },
                );
              },
            ),
          ),
          // Sub Menu
          Container(
            width: 200,
            color: Colors.grey[300],
            child: ListView.builder(
              itemCount: subMenuItems[_selectedMainMenuItemIndex].length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(subMenuItems[_selectedMainMenuItemIndex][index]),
                  selected: _selectedSubMenuItemIndex == index,
                  onTap: () {
                    setState(() {
                      _selectedSubMenuItemIndex = index;
                    });
                  },
                );
              },
            ),
          ),
          // Main Content
          Expanded(
            child: Center(
              child: Text(
                'Main Content: ${mainMenuItems[_selectedMainMenuItemIndex]} > '
                    '${subMenuItems[_selectedMainMenuItemIndex][_selectedSubMenuItemIndex]}',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

List<String> mainMenuItems = ['Menu 1', 'Menu 2', 'Menu 3'];

List<List<String>> subMenuItems = [
  ['Sub-menu 1', 'Sub-menu 2'],
  ['Sub-menu 3', 'Sub-menu 4', 'Sub-menu 5'],
  ['Sub-menu 6'],
];
