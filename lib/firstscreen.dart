import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:async';

class FirstScreen extends StatefulWidget {
  @override
  _FirstScreenState createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen>
    with SingleTickerProviderStateMixin {
  bool _checkApiToken = false;
  @override

  void checkTokenValidity() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';

    if (token != null) {
      // Token exists, check its validity
      final url = 'https://myschool.levnext.com/sms/api/transportapi/profile.php'; // Replace with your API endpoint
      final headers = {'Authorization': token};

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode({'operation': 'Profile'}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if(responseData['result'] == 'success'){
          ///print(responseData);
          setState(() {
            _checkApiToken = true;
          });

            Timer(Duration(seconds: 2), () {
              Navigator.pushNamed(context, '/profile');
            });
          setState(() {
            _checkApiToken = true;
          });
        }else{
          Timer(Duration(seconds: 2), () {
            Navigator.pushNamed(context, '/login');
          });
          setState(() {
            _checkApiToken = true;
          });
        }
      } else {
        print('Failed to check token validity with status: ${response.statusCode}');
        Timer(Duration(seconds: 2), () {
          Navigator.pushNamed(context, '/login');
        });
      }
    }else{
      Timer(Duration(seconds: 2), () {
        Navigator.pushNamed(context, '/login');
      });
    }
  }


  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2500),
    );
    _opacityAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.5).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat(reverse: true);
    super.initState();
    checkTokenValidity();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          ClipPath(
            clipper: WaveClipper(), // Custom clipper for the wave shape
            child: Container(
              color: Color(0xFF048293),
              height: 240.0, // Adjust the height of the wave design
            ),
          ),
          SizedBox(height: 20.0),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: AnimatedOpacity(
                    opacity: 1,
                    duration: Duration(milliseconds: 2500),
                    child: Image.asset(
                      'assets/driver.png', // Replace with your PNG image file path
                      width: 270.0,
                      height: 270.0,
                    ),
                  ),
                ),
                SizedBox(height: 40.0),
                Text(
                  'Getting Started',
                  style: TextStyle(
                    fontSize: 30.0,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF048293),
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: 20.0),
                Container(
                  child: Loader(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height * 0.9);

    final firstControlPoint = Offset(size.width * 0.12, size.height * 1.1);
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

