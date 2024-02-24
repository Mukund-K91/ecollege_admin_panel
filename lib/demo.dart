// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class RollNumberGenerator extends StatefulWidget {
//   @override
//   _RollNumberGeneratorState createState() => _RollNumberGeneratorState();
// }
//
// class _RollNumberGeneratorState extends State<RollNumberGenerator> {
//   TextEditingController _rollNumberController = TextEditingController();
//   String _selectedProgram = 'BCA'; // Default program
//   String _selectedProgramTerm = 'Semester 1'; // Default program term
//   String _selectedDivision = 'A'; // Default division
//
//   @override
//   void initState() {
//     super.initState();
//     _generateRollNumber();
//   }
//
//   Future<void> _generateRollNumber() async {
//     try {
//       final rollNumberDocPath = 'rollno/$_selectedProgram/$_selectedProgramTerm/$_selectedDivision';
//       final rollNumberDocRef = FirebaseFirestore.instance.doc(rollNumberDocPath);
//
//       // Get the current roll number
//       final rollNumberSnapshot = await rollNumberDocRef.get();
//
//       // Increment the roll number
//       final int currentRollNumber = (rollNumberSnapshot.exists)
//           ? (rollNumberSnapshot.data()!['lastRollNumber'] as int) + 1
//           : 1;
//
//       // Update the roll number in Firestore
//       await rollNumberDocRef.set({'lastRollNumber': currentRollNumber});
//
//       // Update the roll number in the text field
//       setState(() {
//         _rollNumberController.text = currentRollNumber.toString();
//       });
//     } catch (e) {
//       print('Error generating roll number: $e');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Roll Number Generator'),
//       ),
//       body: Center(
//         child: Padding(
//           padding: EdgeInsets.all(16.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               DropdownButton<String>(
//                 value: _selectedProgram,
//                 onChanged: (String? value) {
//                   setState(() {
//                     _selectedProgram = value!;
//                   });
//                 },
//                 items: ['BCA', 'BBA', 'B.Com'].map<DropdownMenuItem<String>>((String value) {
//                   return DropdownMenuItem<String>(
//                     value: value,
//                     child: Text(value),
//                   );
//                 }).toList(),
//               ),
//               SizedBox(height: 16.0),
//               DropdownButton<String>(
//                 value: _selectedProgramTerm,
//                 onChanged: (String? value) {
//                   setState(() {
//                     _selectedProgramTerm = value!;
//                   });
//                 },
//                 items: ['Semester 1', 'Semester 2', 'Semester 3'].map<DropdownMenuItem<String>>((String value) {
//                   return DropdownMenuItem<String>(
//                     value: value,
//                     child: Text(value),
//                   );
//                 }).toList(),
//               ),
//               SizedBox(height: 16.0),
//               DropdownButton<String>(
//                 value: _selectedDivision,
//                 onChanged: (String? value) {
//                   setState(() {
//                     _selectedDivision = value!;
//                   });
//                 },
//                 items: ['A', 'B', 'C'].map<DropdownMenuItem<String>>((String value) {
//                   return DropdownMenuItem<String>(
//                     value: value,
//                     child: Text(value),
//                   );
//                 }).toList(),
//               ),
//               SizedBox(height: 16.0),
//               TextFormField(
//                 controller: _rollNumberController,
//                 decoration: InputDecoration(
//                   labelText: 'Roll Number',
//                   border: OutlineInputBorder(),
//                 ),
//                 readOnly: true,
//               ),
//               SizedBox(height: 16.0),
//               ElevatedButton(
//                 onPressed: _generateRollNumber,
//                 child: Text('Generate Roll Number'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// void main() {
//   runApp(MaterialApp(
//     home: RollNumberGenerator(),
//   ));
// }



import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AssignRollPage extends StatefulWidget {
  @override
  _AssignRollPageState createState() => _AssignRollPageState();
}

class _AssignRollPageState extends State<AssignRollPage> {
  late TextEditingController _nameController;
  late List<Map<String, dynamic>> _studentsData = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    fetchStudentsData();
  }

  Future<void> fetchStudentsData() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
      await FirebaseFirestore.instance.collection('students').get();
      setState(() {
        _studentsData = snapshot.docs.map((doc) => doc.data()).toList();
      });
    } catch (e) {
      print('Error fetching students data: $e');
    }
  }

  void generateRollNumbers() {
    setState(() {
      int nextRollNumber = 1;
      for (int i = 0; i < _studentsData.length; i++) {
        _studentsData[i]['rollNumber'] = nextRollNumber.toString().padLeft(3, '0');
        nextRollNumber++;
      }
    });
  }

  Future<void> submitStudents() async {
    try {
      for (int i = 0; i < _studentsData.length; i++) {
        // Update student data with new roll number in Firestore
        await FirebaseFirestore.instance
            .collection('students')
            .doc(_studentsData[i]['userId']) // Assuming you have a 'userId' field in the student data
            .update({'rollNumber': _studentsData[i]['rollNumber']});
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Roll numbers assigned and updated successfully'),
        duration: Duration(seconds: 2),
      ));
    } catch (e) {
      print('Error submitting students: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Assign Roll Numbers'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: generateRollNumbers,
              child: Text('Generate Roll Numbers'),
            ),
            SizedBox(height: 20),
            if (_studentsData.isNotEmpty) ...[
              Text('Students List with Roll Numbers:'),
              SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                itemCount: _studentsData.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('Name: ${_studentsData[index]['name']} - Roll Number: ${_studentsData[index]['rollNumber']}'),
                  );
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: submitStudents,
                child: Text('Submit Students'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}

void main() {
  runApp(MaterialApp(
    home: AssignRollPage(),
  ));
}
