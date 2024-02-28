import 'package:flutter/material.dart';

class MultiSelectDropdown extends StatefulWidget {
  final List<String> options;
  final String title;
  final Function(List<String>) onSelect;

  MultiSelectDropdown({
    required this.options,
    required this.title,
    required this.onSelect,
  });

  @override
  _MultiSelectDropdownState createState() => _MultiSelectDropdownState();
}

class _MultiSelectDropdownState extends State<MultiSelectDropdown> {
  List<String> _selectedOptions = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.title),
        DropdownButtonFormField<String>(
          isExpanded: true,
          value: null,
          items: widget.options.map((option) {
            return DropdownMenuItem<String>(
              value: option,
              child: Text(option),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              if (_selectedOptions.contains(value)) {
                _selectedOptions.remove(value);
              } else {
                _selectedOptions.add(value!);
              }
              widget.onSelect(_selectedOptions);
            });
          },
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: _selectedOptions.map((option) {
            return Chip(
              label: Text(option),
              onDeleted: () {
                setState(() {
                  _selectedOptions.remove(option);
                  widget.onSelect(_selectedOptions);
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}

// Example usage:
class MyHomePage extends StatelessWidget {
  final List<String> options = ['Option 1', 'Option 2', 'Option 3'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Multi-select Dropdown Example'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: MultiSelectDropdown(
          title: 'Select Options',
          options: options,
          onSelect: (selectedOptions) {
            print('Selected options: $selectedOptions');
          },
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: MyHomePage(),
  ));
}
