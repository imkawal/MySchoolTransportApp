import 'package:flutter_dialogs/flutter_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:wakelock/wakelock.dart';
import 'package:fluttertoast/fluttertoast.dart';


class Attendance extends StatefulWidget {
  @override
  _AttendanceState createState() => _AttendanceState();
}

class _AttendanceState extends State<Attendance> {
  void sendCustomSMS(String recipient, String message) async {
    print('1');
  }

  DateTime currentDate = DateTime.now();
  bool isApiDataLoaded = false;
  String token = '';
  String selectedOption = 'IN';
  String _selectedOption = "IN-TIME";
  dynamic recordIDs = [];
  dynamic ApiData;
  int Present = 0;
  int Leave = 0;
  int Waiting = 0;

  @override
  void initState() {
    super.initState();
    getToken().then((value) {
      initApiData(Date, selectedOption);
    });
    _updateSelectedOption();
    Wakelock.enable();
  }

  void _updateSelectedOption() {
    DateTime currentTime = DateTime.now();
    TimeOfDay morningStartTime = TimeOfDay(hour: 5, minute: 0);
    TimeOfDay morningEndTime = TimeOfDay(hour: 11, minute: 0);

    TimeOfDay currentTimeOfDay = TimeOfDay.fromDateTime(currentTime);

    if (currentTimeOfDay.hour > morningEndTime.hour ||
        (currentTimeOfDay.hour == morningEndTime.hour &&
            currentTimeOfDay.minute >= morningEndTime.minute)) {
      setState(() {
        selectedOption = 'OUT';
        _selectedOption = 'OUT-TIME';
      });
    } else {
      setState(() {
        selectedOption = 'IN';
        _selectedOption = 'IN-TIME';
      });
    }
  }

  Future<void> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token') ?? '';
    });
  }

  Future<void> initApiData(String date, selectedOption) async {
    try {
      setState(() {
        isApiDataLoaded = false;
      });
      final inputFormat = DateFormat('dd/MM/yyyy');
      final dateObject = inputFormat.parse(date);
      final url =
          'https://myschool.levnext.com/sms/api/transportapi/ShowStudentAttendance.php'; // Replace with your API endpoint
      final headers = {'Authorization': '$token'};

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode({
          'operation': 'ShowStudentAttendance',
          'Date': '${DateFormat('yyyy-MM-dd').format(dateObject)}',
          'Shift': '${selectedOption}'
        }),
      );

      if (response.statusCode == 200) {
        // API request was successful
        final responseData = jsonDecode(response.body);
        Map<String, dynamic> responseDa = jsonDecode(response.body);
        setState(() {
          recordIDs = responseDa['data']
              .map<int>((item) => int.tryParse(item['RecordID']) ?? 0)
              .toList();
        });
        print(recordIDs);
        setState(() {
          ApiData = responseData['data'];
          Present = ApiData[0]['Present'];
          Leave = ApiData[0]['Leave'];
          Waiting = ApiData[0]['Waiting'];
          setState(() {
            isApiDataLoaded = true;
          });
        });
      } else {
        // API request failed
        print('API request failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      // Error occurred during API request
      print('Error: $e');
    }
  }

  var Date = DateFormat('dd/MM/yyyy').format(DateTime.now());

  Future<void> sendSMS(
       classStudentIDs, String status, String to) async {
    try {
      print(classStudentIDs);
      final url =
          'https://myschool.levnext.com/sms/api/transportapi/SendAttdMsg.php'; // Replace with your API endpoint
      final headers = {'Authorization': '$token'};

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode({
          'operation': 'SendAttdMsg',
          'ClassStudentID': classStudentIDs,
          'Status': status,
          'To': to,
        }),
      );

      if (response.statusCode == 200) {
        // API request was successful
        final responseData = jsonDecode(response.body);
        print(responseData);
      } else {
        // API request failed
        print('API request failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      // Error occurred during API request
      print('Error: $e');
    }
  }

  Future<void> sendAllSMS(classStudentIDs, String status, String to) async {
     initApiData(Date, selectedOption);
     for(var item in ApiData){
            if(item['Attedance'] == 'IN' || item['Attedance'] == 'OUT'){
              String status = '';
              String to = '';
              item['Attedance'] == 'IN' && selectedOption =='IN' ? status = 'BOARDED-IN' : ' ';
              item['Attedance'] == 'IN' && selectedOption == 'IN' ? to = 'School' : ' ';
              item['Attedance'] == 'IN' && selectedOption == 'OUT' ? status = 'BOARDED-IN' : ' ';
              item['Attedance'] == 'IN' && selectedOption == 'OUT' ? to = 'Home' : ' ';

              item['Attedance'] == 'OUT' && selectedOption =='IN' ? status = 'BOARDED-OUT' : ' ';
              item['Attedance'] == 'OUT' && selectedOption == 'IN' ? to = 'School' : ' ';
              item['Attedance'] == 'OUT' && selectedOption == 'OUT' ? status = 'BOARDED-OUT' : ' ';
              item['Attedance'] == 'OUT' && selectedOption == 'OUT' ? to = 'Home' : ' ';
              sendSMS(item['ClassStudentID'],
                  status, to);
            }
     }

     Fluttertoast.showToast(
       msg: "Notification Sent!",
       toastLength: Toast.LENGTH_SHORT,
       gravity: ToastGravity.BOTTOM,
       timeInSecForIosWeb: 1,
       backgroundColor: Colors.black,
       textColor: Colors.white,
       fontSize: 16.0,
     );
  }

  DateTime lastDate = DateTime.now();
  String CheckAttd = 'P';
  List<String> attendanceStatusList = List.generate(10, (index) => 'P');
  List<String> attendanceStatusColor =
      List.generate(10, (index) => '0xFF00af12');
  TextEditingController _dateController =
      TextEditingController(text: DateFormat('dd/MM/yyyy').format(DateTime.now()));

  GlobalKey _menuButtonKey = GlobalKey();

  Future<void> _selectDate(BuildContext context) async {
    final RenderBox button =
        _menuButtonKey.currentContext!.findRenderObject() as RenderBox;
    final offset = button.localToGlobal(Offset.zero);

    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2001),
      lastDate: lastDate,
      builder: (BuildContext context, Widget? child) {
        return Positioned(
          top: offset.dy +
              button.size.height, // Adjust the position as per your requirement
          left: offset.dx, // Adjust the position as per your requirement
          child:Theme(
            data: ThemeData.light().copyWith(
              // Customize the colors here
              primaryColor: Color(0xFF048293), // Change the primary color
              colorScheme: ColorScheme.light(
                primary: Color(0xFF048293), // Change the color scheme's primary color
                // Additional color options can be provided here if needed
              ),
            ),
            child: child!,
          ),
        );
      },
    );
    if (selectedDate != null) {
      setState(() {
        currentDate = selectedDate;
        _dateController.text = DateFormat('dd/MM/yyyy').format(currentDate);
        initApiData(_dateController.text, selectedOption);
      });
    }
  }

  Future<void> updateAttd(RecordID, value, action) async {
    if(action == 'All'){
      setState(() {
        isApiDataLoaded = false;
      });
    }
    String numbersString = RecordID.join(", ");
    try {
      final url = 'https://myschool.levnext.com/sms/api/transportapi/UpdateAttendance.php'; // Replace with your API endpoint
      final headers = {'Authorization': '$token'};
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode({
          'operation': 'UpdateAttendance',
          'RecordID': numbersString,
          'Attendance': '$value',
          'action' : action,
        }),
      );
      print(response.body);
      if (response.statusCode == 200) {
        // API request was successful
        if (response.body.isNotEmpty) {
          try {
            // Try to parse the response as JSON
            final responseData = jsonDecode(response.body);
             if(action == 'All') {
               initApiData(
                   _dateController.text,
                   selectedOption);
             }
          } catch (e) {
            // If parsing fails, handle the response as plain text
            print('Response is not in valid JSON format. Response Body: ${response.body}');
          }
        } else {
          print('Empty response received.');
        }
      } else {
        // API request failed
        print('API request failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      // Error occurred during API request
      print('Error: $e');
    }
  }


  void _openModal(
      BuildContext context, image, Name, Attd, FatherName, Stoppage, Phone) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          margin: EdgeInsets.only(
            left: MediaQuery.of(context).size.width * 0.03,
            right: MediaQuery.of(context).size.height * 0.019,
          ),
          child: Stack(
            children: [
              Container(
                margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.2,),
                decoration: BoxDecoration(
                  color: Color(0xFF048293),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.094,
                ),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Image.asset(
                    'assets/driver.png', // Replace with your image path
                    width: 150,
                    height: 150,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.24,
                ),
                height: MediaQuery.of(context).size.height * 0.6,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                  ),
                ),
                child: Center(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 5,
                      ),
                      CircleAvatar(
                        backgroundImage: NetworkImage(
                          '${image}',
                        ),
                        radius: 28.0,
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 3),
                        child: Center(
                          child: Text(
                            "${Name}",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF048293),
                                fontSize: 18.0),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      Container(
                        margin: EdgeInsets.only(
                          left: 15,
                        ),
                        child: Row(
                          children: [
                            Flexible(
                              flex: 1,
                              fit: FlexFit.tight,
                              child: Container(
                                  child: Icon(
                                Icons.person_pin_outlined,
                                size: 25,
                                color: Color(0xFF048293),
                              )),
                            ),
                            Flexible(
                              flex: 4,
                              fit: FlexFit.tight,
                              child: Container(
                                child: Text(
                                  '${FatherName}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                          margin: EdgeInsets.only(
                            left: 15,
                          ),
                          child: Row(
                            children: [
                              Flexible(
                                flex: 1,
                                fit: FlexFit.tight,
                                child: Container(
                                    child: Icon(
                                  Icons.call,
                                  size: 25,
                                  color: Color(0xFF048293),
                                )),
                              ),
                              Flexible(
                                flex: 4,
                                fit: FlexFit.tight,
                                child: Container(
                                  child: Text(
                                    '${Phone}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        margin: EdgeInsets.only(
                          left: 15,
                        ),
                        child: Row(
                          children: [
                            Flexible(
                              flex: 1,
                              fit: FlexFit.tight,
                              child: Container(
                                  child: Icon(
                                Icons.bus_alert_sharp,
                                size: 25,
                                color: Color(0xFF048293),
                              )),
                            ),
                            Flexible(
                              flex: 4,
                              fit: FlexFit.tight,
                              child: Container(
                                child: Text(
                                  '${Stoppage}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      Container(
                          margin: EdgeInsets.only(left: 12),
                          child: Row(
                            children: [
                              Flexible(
                                flex: 1,
                                fit: FlexFit.tight,
                                child: Container(
                                    child: Icon(
                                  Icons.check_box,
                                  size: 25,
                                  color: Color(0xFF048293),
                                )),
                              ),
                              Flexible(
                                flex: 4,
                                fit: FlexFit.tight,
                                child: Container(
                                  child: Text(
                                    '${Attd}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13),
                                  ),
                                ),
                              ),
                            ],
                          )),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          "Attendance",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFF048293),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Color(0xFF048293),
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 9.0),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.only(top: 1.0),
                            hintText: 'Date',
                            hintStyle: TextStyle(
                              color: Color(0xFF048293),
                              fontSize: 16.0,
                            ),
                            prefixIcon: IconButton(
                              key: _menuButtonKey,
                              onPressed: () => _selectDate(context),
                              icon: Icon(Icons.calendar_today_rounded),
                              color: Color(0xFF048293),
                            ),
                          ),
                          child: TextField(
                            enabled: false,
                            style: TextStyle(
                              color: Color(0xFF048293),
                              fontSize: 16.0,
                            ),
                            controller: _dateController,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Color(0xFF048293),
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: LayoutBuilder(
                        builder:
                            (BuildContext context, BoxConstraints constraints) {
                          return Row(
                            children: [
                              Container(
                                margin: EdgeInsets.only(left: 10),
                                child: Icon(
                                  Icons.group_add_outlined,
                                  color: Color(0xFF048293),
                                ),
                              ),
                              Expanded(
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding:
                                        EdgeInsets.symmetric(horizontal: 8.0),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () {
                                            setState(() {
                                              if (selectedOption == 'IN') {
                                                selectedOption = 'OUT';
                                                _selectedOption = "OUT-TIME";
                                                initApiData(
                                                    _dateController.text,
                                                    selectedOption);
                                              } else {
                                                selectedOption = 'IN';
                                                _selectedOption = "IN-TIME";
                                                initApiData(
                                                    _dateController.text,
                                                    selectedOption);
                                              }
                                            });
                                          },
                                          style: ElevatedButton.styleFrom(
                                            primary: Colors
                                                .transparent, // Set the button background color to transparent
                                            elevation:
                                                0, // Remove the button elevation
                                          ),
                                          child: Text(
                                            _selectedOption,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Color(0xFF048293),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 9.0,
              ),
              if (!isApiDataLoaded)
                Center(
                  child: buildLoader(),
                )
              else
                Container(
                  margin: EdgeInsets.only(left: 10, right: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          width: 84.0,
                          height: 70.0,
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Color(0xFF048293), width: 2.0),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Column(
                            children: [
                              Container(
                                  width: 100.0,
                                  height: 40.0,
                                  decoration: BoxDecoration(
                                    color: Color(0xFF048293),
                                    borderRadius: BorderRadius.only(
                                      bottomRight: Radius.circular(7.0),
                                      bottomLeft: Radius.circular(7.0),
                                      topLeft: Radius.circular(7.0),
                                      topRight: Radius.circular(7.0),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      ApiData[0]['TotalStudent'],
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )),
                              Container(
                                margin: EdgeInsets.only(top: 8),
                                child: Center(
                                  child: Text(
                                    "Total",
                                    style: TextStyle(
                                      fontSize: 11.0,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1f6973),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Container(
                          width: 84.0,
                          height: 70.0,
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Color(0xFF00af12), width: 2.0),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Column(
                            children: [
                              Container(
                                  width: 100.0,
                                  height: 40.0,
                                  decoration: BoxDecoration(
                                    color: Color(0xFF00af12),
                                    borderRadius: BorderRadius.only(
                                      bottomRight: Radius.circular(7.0),
                                      bottomLeft: Radius.circular(7.0),
                                      topLeft: Radius.circular(7.0),
                                      topRight: Radius.circular(7.0),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '$Present',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )),
                              Container(
                                margin: EdgeInsets.only(top: 8),
                                child: Center(
                                  child: Text(
                                    "IN",
                                    style: TextStyle(
                                      fontSize: 11.0,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1f6973),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Container(
                          width: 84.0,
                          height: 70.0,
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Color(0xFF4656e0), width: 2.0),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Column(
                            children: [
                              Container(
                                  width: 100.0,
                                  height: 40.0,
                                  decoration: BoxDecoration(
                                    color: Color(0xFF4656e0),
                                    borderRadius: BorderRadius.only(
                                      bottomRight: Radius.circular(7.0),
                                      bottomLeft: Radius.circular(7.0),
                                      topLeft: Radius.circular(7.0),
                                      topRight: Radius.circular(7.0),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${Leave}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )),
                              Container(
                                margin: EdgeInsets.only(top: 8),
                                child: Center(
                                  child: Text(
                                    "Leave",
                                    style: TextStyle(
                                      fontSize: 11.0,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1f6973),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 10,),
                      Expanded(
                        child: Container(
                          width: 84.0,
                          height: 70.0,
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Color(0xFFea4d4d), width: 2.0),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Column(
                            children: [
                              Container(
                                  width: 100.0,
                                  height: 40.0,
                                  decoration: BoxDecoration(
                                    color: Color(0xFFea4d4d),
                                    borderRadius: BorderRadius.only(
                                      bottomRight: Radius.circular(7.0),
                                      bottomLeft: Radius.circular(7.0),
                                      topLeft: Radius.circular(7.0),
                                      topRight: Radius.circular(7.0),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${Waiting}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )),
                              Container(
                                margin: EdgeInsets.only(top: 8),
                                child: Center(
                                  child: Text(
                                    "Waiting",
                                    style: TextStyle(
                                      fontSize: 11.0,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1f6973),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              SizedBox(
                height: 6.0,
              ),
              if (isApiDataLoaded)
              Container(
                margin: EdgeInsets.only(left: 10, right: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Color(0xFF048293),
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Confirmation'),
                                  content: Text(
                                      'Are you sure you want to mark ${selectedOption == 'OUT' ? 'IN' : 'OUT'} for all students?'),
                                  actions: <Widget>[
                                    TextButton(
                                      child: Text('Cancel'),
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pop(); // Dismiss the dialog
                                      },
                                    ),
                                    TextButton(
                                      child: Text('Mark All'),
                                      onPressed: () {
                                        String status = '';
                                        String to = '';

                                        if (selectedOption == 'IN') {
                                          status = 'BOARDED-IN';
                                          to = 'School';
                                        } else if (selectedOption == 'OUT') {
                                          status = 'BOARDED-OUT';
                                          to = 'Home';
                                        }

                                        print(recordIDs);
                                        updateAttd(recordIDs, selectedOption == 'OUT' ? 'IN' : 'OUT', 'All');

                                        Navigator.of(context)
                                            .pop(); // Dismiss the dialog// Dismiss the dialog
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Row(
                            children: [
                              Icon(Icons.check_circle_outlined),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                "Mark All ${selectedOption == 'OUT' ? 'IN' : 'OUT'}",
                                style: TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      child: Container(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Color(0xFF048293),
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Confirmation'),
                                  content: Text(
                                      'Are you sure you want to notify all present students to Parents?'),
                                  actions: <Widget>[
                                    TextButton(
                                      child: Text('Cancel'),
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pop(); // Dismiss the dialog
                                      },
                                    ),
                                    TextButton(
                                      child: Text('Notify'),
                                      onPressed: () {
                                        String status = '';
                                        String to = '';

                                        if (selectedOption == 'IN') {
                                          status = 'BOARDED-OUT';
                                          to = 'School';
                                        } else if (selectedOption == 'OUT') {
                                          status = 'BOARDED-IN';
                                          to = 'Home';
                                        }

                                        print(ApiData[0]['AllClassStudentArr']);
                                        sendAllSMS(
                                            ApiData[0]['AllClassStudentArr'],
                                            status,
                                            to);
                                        Navigator.of(context)
                                            .pop(); // Dismiss the dialog// Dismiss the dialog
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Row(
                            children: [
                              Icon(Icons.message),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                "Notify All Boarded",
                                style: TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (isApiDataLoaded)
              Container(
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Color(0xFF048293),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                margin: EdgeInsets.only(left: 10, right: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(left: 20.0),
                        child: Text(
                          "N",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        child: Text(
                          "Student",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          "Attendance",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (isApiDataLoaded)
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 10, right: 10, top: 10),
                  child: ListView.builder(
                    itemCount: !isApiDataLoaded ? 1 : ApiData.length,
                    itemBuilder: (context, index) {
                      if (!isApiDataLoaded) {
                        return Center(child: CircularProgressIndicator());
                      }

                      if (ApiData[index]['Attedance'] == 'IN') {
                        ApiData[index]['Attedance'] = 'IN';
                        attendanceStatusColor[index] = '0xFF00af12';
                        attendanceStatusList[index] = 'IN';
                      } else if (ApiData[index]['Attedance'] == 'L') {
                        ApiData[index]['Attedance'] = 'L';
                        attendanceStatusColor[index] = '0xFF4656e0';
                        attendanceStatusList[index] = 'L';
                      } else if (ApiData[index]['Attedance'] == 'OUT') {
                        ApiData[index]['Attedance'] = 'OUT';
                        attendanceStatusColor[index] = '0xFFFFA500';
                        attendanceStatusList[index] = 'OUT';
                      } else {
                        ApiData[index]['Attedance'] = 'NM';
                        attendanceStatusColor[index] = '0xFFea4d4d';
                        attendanceStatusList[index] = 'NM';
                      }

                      return Container(
                        height: 85.0, // Adjust the desired height
                        margin: EdgeInsets.symmetric(vertical: 2.0),
                        child: Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                                color: Color(0xFF048293), width: 2.0),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Row(
                            children: [
                              Container(
                                margin: EdgeInsets.only(left: 15.0),
                                child: Text(
                                  '${index + 1}.',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0,
                                    color: Color(0xFF048293),
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.0),
                              GestureDetector(
                                onTap: () {
                                  _openModal(
                                      context,
                                      ApiData[index]['Image'],
                                      ApiData[index]['StudentName'],
                                      ApiData[index]['Attedance'],
                                      ApiData[index]['FatherName'],
                                      ApiData[index]['Stoppage'],
                                      ApiData[index]['Phone']);
                                },
                                child: CircleAvatar(
                                  backgroundImage: NetworkImage(
                                    '${ApiData[index]['Image']}',
                                  ),
                                  radius: 25.0,
                                ),
                              ),
                              SizedBox(width: 8.0),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      ApiData[index]['StudentName'],
                                      style: TextStyle(
                                        color: Color(0xFF005460),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      ApiData[index]['FatherName'] != null
                                          ? ApiData[index]['FatherName']
                                          : ' ',
                                      style: TextStyle(
                                        color: Color(0xFF005460),
                                        fontSize: 11.7,
                                      ),
                                    ),
                                    Text(
                                      ApiData[index]['Stoppage'] != null
                                          ? ApiData[index]['Stoppage']
                                          : ' ',
                                      style: TextStyle(
                                        color: Color(0xFF148a9a),
                                        fontSize: 11.7,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 8.0),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Column(
                                    children: [
                                      Expanded(
                                        child: IconButton(
                                          onPressed: () {
                                            final phoneNumber = ApiData[index]
                                                        ['Phone'] !=
                                                    null
                                                ? ApiData[index]['Phone']
                                                : ' '; // Replace with the desired phone number
                                            launch('tel:$phoneNumber');
                                          },
                                          icon: Icon(
                                            Icons.phone,
                                            color: Color(int.parse(
                                                attendanceStatusColor[index])),
                                            size: 27.0,
                                          ),
                                        ),
                                      ),
                                      if (ApiData[index]['Attedance'] == 'IN' || ApiData[index]['Attedance'] == 'OUT')
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () {
                                              showPlatformDialog(
                                                context: context,
                                                builder: (_) =>
                                                    BasicDialogAlert(
                                                  title: Text("Confirmation"),
                                                  content: Text(
                                                      "Are you sure you want to send the SMS?"),
                                                  actions: <Widget>[
                                                    BasicDialogAction(
                                                      title: Text("Cancel"),
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop(); // Dismiss the dialog
                                                      },
                                                    ),
                                                    BasicDialogAction(
                                                      title: Text("Send"),
                                                      onPressed: () {
                                                        List<int>
                                                            classStudentIDs = [
                                                          int.parse(ApiData[
                                                                      index][
                                                                  'ClassStudentID']
                                                              .toString())
                                                        ];
                                                        String status = '';
                                                        String to = '';
                                                        attendanceStatusList[index] == 'IN' && selectedOption =='IN' ? status = 'BOARDED-IN' : ' ';
                                                        attendanceStatusList[index] == 'IN' && selectedOption == 'IN' ? to = 'School' : ' ';
                                                        attendanceStatusList[index] == 'IN' && selectedOption == 'OUT' ? status = 'BOARDED-IN' : ' ';
                                                        attendanceStatusList[index] == 'IN' && selectedOption == 'OUT' ? to = 'Home' : ' ';

                                                        attendanceStatusList[index] == 'OUT' && selectedOption =='IN' ? status = 'BOARDED-OUT' : ' ';
                                                        attendanceStatusList[index] == 'OUT' && selectedOption == 'IN' ? to = 'School' : ' ';
                                                        attendanceStatusList[index] == 'OUT' && selectedOption == 'OUT' ? status = 'BOARDED-OUT' : ' ';
                                                        attendanceStatusList[index] == 'OUT' && selectedOption == 'OUT' ? to = 'Home' : ' ';
                                                        sendSMS(ApiData[
                                                        index][
                                                        'ClassStudentID'],
                                                            status, to);
                                                        Fluttertoast.showToast(
                                                          msg: "Message Sent!",
                                                          toastLength: Toast.LENGTH_SHORT,
                                                          gravity: ToastGravity.BOTTOM,
                                                          timeInSecForIosWeb: 1,
                                                          backgroundColor: Colors.black,
                                                          textColor: Colors.white,
                                                          fontSize: 16.0,
                                                        );
                                                        Navigator.of(context)
                                                            .pop(); // Dismiss the dialog
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                            child: IconButton(
                                              onPressed: null,
                                              // Set onPressed as null to disable the button
                                              icon: Icon(
                                                Icons.mail,
                                                color: Color(int.parse(
                                                    attendanceStatusColor[
                                                        index])),
                                                size: 27.0,
                                              ),
                                            ),
                                          ),
                                        ),
                                      SizedBox(
                                        height: 5.0,
                                      ),
                                    ],
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        //0xFFBF40BF
                                        if(attendanceStatusList[index] == 'NM') {
                                          Waiting = Waiting - 1;
                                        };

                                        if (attendanceStatusList[index] ==
                                            'IN') {
                                          ApiData[index]['Attedance'] = 'OUT';
                                          attendanceStatusColor[index] =
                                              '0xFFFFA500';
                                          attendanceStatusList[index] = 'OUT';
                                          setState(() {
                                            Present = Present - 1;
                                          });
                                        } else if (attendanceStatusList[index] ==
                                            'OUT') {
                                          ApiData[index]['Attedance'] = 'L';
                                          attendanceStatusColor[index] =
                                              '0xFF4656e0';
                                          attendanceStatusList[index] = 'L';
                                          setState(() {
                                            Leave = Leave + 1;
                                          });
                                        } else if (attendanceStatusList[index] ==
                                            'L') {
                                          ApiData[index]['Attedance'] = '';
                                          attendanceStatusColor[index] =
                                          '0xFFea4d4d';
                                          attendanceStatusList[index] = 'NM';
                                          Waiting = Waiting + 1;
                                          Leave != 0 ? Leave = Leave - 1 : 0;
                                        } else {
                                          ApiData[index]['Attedance'] = 'IN';
                                          attendanceStatusColor[index] =
                                              '0xFF00af12';
                                          attendanceStatusList[index] = 'IN';
                                          setState(() {
                                            Present = Present + 1;
                                            Leave != 0 ? Leave = Leave - 1 : 0;
                                          });
                                        }

                                        List<int>
                                        classStudentIDs = [
                                          int.parse(ApiData[
                                          index][
                                          'RecordID']
                                              .toString())
                                        ];
                                        updateAttd(classStudentIDs,
                                            ApiData[index]['Attedance'], ' ');
                                      });
                                    },
                                    child: Container(
                                      margin: EdgeInsets.only(
                                        top: 8,
                                        bottom: 8,
                                      ),
                                      padding: EdgeInsets.all(10),
                                      width: 50.0,
                                      decoration: BoxDecoration(
                                        color: Color(int.parse(
                                            attendanceStatusColor[index])),
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      child: Center(
                                        child: Text(
                                          ApiData[index]['Attedance'] != null
                                              ? attendanceStatusList[index]
                                              : '',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontSize: 12.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(width: 8.0),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Widget buildLoader() {
  return Container(
    color: Colors.white, // Transparent white background
    child: Center(
      child: Loader(), // Loader widget
    ),
  );
}

class Loader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SpinKitThreeBounce(
        color: Color(0xFF048293),
        size: 40.0,
      ),
    );
  }
}
