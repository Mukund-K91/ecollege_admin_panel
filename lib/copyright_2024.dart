import 'package:flutter/material.dart';

class CopyrightFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200], // Background color for the footer
      padding: EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            '© ${DateTime.now().year} Team Aarambh', // Replace "Your Company Name" with your actual company name
            style: TextStyle(
              fontSize: 14.0,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}