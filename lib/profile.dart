import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Profile extends StatefulWidget {
  @override
  _Profile createState() => _Profile();
}

class _Profile extends State<Profile> {
  String token = '';
  dynamic profileData;
  bool isApiDataLoaded = false;

  @override
  void initState() {
    super.initState();
    getToken().then((value) {
      initProfileData();
    });
  }

  Future<void> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token') ?? '';
    });
  }

  Future<void> initProfileData() async {
    try {
      setState(() {
        isApiDataLoaded = false;
      });
      final url = 'https://myschool.levnext.com/sms/api/transportapi/profile.php'; // Replace with your API endpoint
      final headers = {'Authorization': '$token'};

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode({'operation': 'Profile'}),
      );

      if (response.statusCode == 200) {
        // API request was successful
        final responseData = jsonDecode(response.body);
        setState(() {
          profileData = responseData['data']; // Store the profile data in a state variable
          isApiDataLoaded = true;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          // image: DecorationImage(
          //   image: AssetImage('assets/bgimg.png'),
          //   fit: BoxFit.cover,
          // ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/transport.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Container(
                    color: Color(0xFF048293).withOpacity(0.5), // Adjust the opacity as needed
                  ),
                ],
              ),
            ),
            Positioned.fill(
              bottom: 0,
              child: ClipPath(
                clipper: WaveClipper(),
                child: Container(
                  height: 30,
                  color: Color(0xFF048293).withOpacity(0.5),
                ),
              ),
            ),
            SizedBox(
              height:10,
            ),
            if(!isApiDataLoaded)
              Column(
                 children: [
                     SizedBox(height: 200,),
                     Center(child: Loader(),),
                     SizedBox(height: 227,),
                 ],
              )
            else
            Container(
              child: Column(
                 children: [
                   Container(
                     child: CircleAvatar(
                       backgroundImage: NetworkImage(
                           '${profileData != null ? profileData[0]['Photo'] : ''}'),
                       radius: 50, // Adjust the radius as needed
                     ),
                   ),
                   Container(
                     margin: EdgeInsets.only(top: 15, left: 25, right: 20),
                     child: Row(
                       children: [
                         Flexible(
                           flex: 3,
                           fit: FlexFit.tight,
                           child: Container(
                               child: Icon(Icons.person_outline_outlined, size: 25,)
                           ),
                         ),
                         Flexible(
                           flex: 4,
                           fit: FlexFit.tight,
                           child: Container(
                             child: Text(
                               profileData != null ? profileData[0]['Name'] : '',
                               style: TextStyle(
                                   fontWeight: FontWeight.bold, fontSize: 20),
                             ),
                           ),
                         ),
                       ],
                     ),
                   ),
                   Container(
                     margin: EdgeInsets.only(top: 25, left: 25, right: 20),
                     child: Row(
                       children: [
                         Flexible(
                           flex: 3,
                           fit: FlexFit.tight,
                           child: Container(
                               child: Icon(Icons.person_pin_outlined)
                           ),
                         ),
                         Flexible(
                           flex: 4,
                           fit: FlexFit.tight,
                           child: Container(
                             child: Text(
                               profileData != null ? profileData[0]['Designation'] : '',
                               style: TextStyle(
                                   fontWeight: FontWeight.bold, fontSize: 20),
                             ),
                           ),
                         ),
                       ],
                     ),
                   ),
                   Container(
                     margin: EdgeInsets.only(top: 25, left: 25, right: 20),
                     child: Row(
                       children: [
                         Flexible(
                           flex: 3,
                           fit: FlexFit.tight,
                           child: Container(
                               child: Icon(Icons.call)
                           ),
                         ),
                         Flexible(
                           flex: 4,
                           fit: FlexFit.tight,
                           child: Container(
                             child: Text(
                               profileData != null ? profileData[0]['PhoneNumber'] : '',
                               style: TextStyle(
                                   fontWeight: FontWeight.bold, fontSize: 20),
                             ),
                           ),
                         ),
                       ],
                     ),
                   ),
                   Container(
                     margin: EdgeInsets.only(top: 25, left: 25, right: 20),
                     child: Row(
                       children: [
                         Flexible(
                           flex: 3,
                           fit: FlexFit.tight,
                           child: Container(
                               child: Icon(Icons.bus_alert_sharp)
                           ),
                         ),
                         Flexible(
                           flex: 4,
                           fit: FlexFit.tight,
                           child: Container(
                             child: Text(
                               profileData != null ? profileData[0]['Route'] : '',
                               style: TextStyle(
                                   fontWeight: FontWeight.bold, fontSize: 20),
                             ),
                           ),
                         ),
                       ],
                     ),
                   ),
                   SizedBox(
                     height: 15,
                   ),
                   Container(
                     margin: EdgeInsets.only(top: 20, bottom: 70),
                     width: 200,
                     height: 50,
                     child: ElevatedButton(
                       onPressed: () {
                         Navigator.pushNamed(context, '/Attendance');
                       },
                       style: ButtonStyle(
                         shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                           RoundedRectangleBorder(
                             borderRadius: BorderRadius.circular(15),
                           ),
                         ),
                         backgroundColor:
                         MaterialStateProperty.all<Color>(Color(0xFF048293)),
                       ),
                       child: Text(
                         'Continue',
                         style: TextStyle(
                           color: Colors.white,
                           fontWeight: FontWeight.bold,
                         ),
                       ),
                     ),
                   ),
                 ],
              ),
            ),
            Positioned.fill(
              bottom: 0,
              child: ClipPath(
                child: Container(
                  height: 30,
                  color: Color(0xFF048293).withOpacity(0.7),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height * 0.9);

    final firstControlPoint = Offset(size.width * 0.25, size.height * 1.1);
    final firstEndPoint = Offset(size.width * 0.5, size.height * 0.75);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    final secondControlPoint = Offset(size.width * 0.75, size.height * 0.6);
    final secondEndPoint = Offset(size.width, size.height * 0.9);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, size.height * 0.9);
    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(WaveClipper oldClipper) => false;
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







