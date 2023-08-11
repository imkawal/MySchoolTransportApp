import 'package:flutter/material.dart';
import 'forgotpassword.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> with SingleTickerProviderStateMixin {
  bool _obscureText = true;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  String _errorText = '';
  bool _isLoading = false;
  bool _checkApiToken = false;
  bool ShowUi = false;

  @override
  void initState() {
    super.initState();
  }

  void authenticate(String username, String password) async {
    setState(() {
      _isLoading = true; // Show loader
    });

    var url = Uri.parse('https://myschool.levnext.com/sms/api/transportapi/login.php');
    var response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'UserName': username, 'Password': password, 'operation': 'Login'}),
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data['result'] == 'success') {
        var token = data['token'];
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        Navigator.pushNamed(context, '/profile');
      } else if(data['message'] == 'Wrong Password'){
        setState(() {
          _errorText = 'Pass';
        });
      }else {
          setState(() {
            _errorText = 'Both';
          });
      }
    } else {
      print('Authentication failed with status: ${response.statusCode}');
    }

    setState(() {
      _isLoading = false; // Hide loader
    });
  }


  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double gapHeight = screenHeight * 0.21;

    return
      Visibility(
        visible: true, // Hide the login screen when isLoading is true
        child:Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/bgimg.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 20),
            padding: EdgeInsets.all(40),
            child: Column(
              children: [
                Container(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    "Welcome!",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 38,
                    ),
                  ),
                ),
                SizedBox(height: gapHeight),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 1),
                    child: Text(
                      "Login",
                      style: TextStyle(
                        fontSize: 22,
                        color: Color(0xFF005460),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 1),
                    child: Text(
                      "Enter your ID and password",
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF005460),
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 10),
                  child: TextField(
                    style: TextStyle(
                      color: Color(0xFF005460),
                    ),
                    controller: _nameController,
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide(
                          color: _errorText == 'Name' || _errorText == 'Both' ? Colors.red : Color(0xFF999999),
                          width: 2.0,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          color:  _errorText == 'Name' || _errorText == 'Both' ? Colors.red : Color(0xFF999999), // Change this to the desired enabled border color
                          width: 2.0,
                        ),
                      ),
                      prefixIcon: Icon(
                        Icons.person_outline_outlined,
                        color: Color(0xFF005460),
                      ),
                      hintText: "User Name",
                      hintStyle: TextStyle(
                        color: Color(0xFF005460),
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ),
                AnimatedSwitcher(
                  duration: Duration(milliseconds: 200),
                  child: _errorText == 'Name' || _errorText == 'Both'
                      ? Container(
                    key: Key('error-container'),
                    margin: EdgeInsets.only(top: 5, left: 10),
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      "Please enter valid name",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.red,
                      ),
                    ),
                  )
                      : SizedBox(height: 20),
                ),
                Container(
                  margin: EdgeInsets.only(top: 10),
                  child: TextField(
                    style: TextStyle(
                      color: Color(0xFF005460),
                    ),
                    controller: _passwordController,
                    obscureText: _obscureText,
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide(
                          color: _errorText == 'Pass' || _errorText == 'Both' ? Colors.red : Color(0xFF999999),
                          width: 2.0,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          color: _errorText == 'Pass' || _errorText == 'Both' ? Colors.red : Color(0xFF999999),// Change this to the desired enabled border color
                          width: 2.0,
                        ),
                      ),
                      prefixIcon: Icon(
                        Icons.lock_open_outlined,
                        color: Color(0xFF005460),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureText
                            ? Icons.visibility_off_sharp
                            : Icons.visibility),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
                      hintText: "Password",
                      hintStyle: TextStyle(
                        color: Color(0xFF005460),
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ),
                AnimatedSwitcher(
                  duration: Duration(milliseconds: 200),
                  child: _errorText == 'Pass' || _errorText == 'Both'
                      ? Container(
                    key: Key('error-container'),
                    margin: EdgeInsets.only(top: 5, left: 10),
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      "Please enter valid password",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.red,
                      ),
                    ),
                  )
                      : SizedBox(height: 10),
                ),
                Container(
                  margin: EdgeInsets.only(top: 15),
                  width: 320,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      String username = _nameController.text.trim();
                      String password = _passwordController.text.trim();

                      if(password.isEmpty && username.isEmpty){
                        setState(() {
                          _errorText = 'Both';
                        });
                        return;
                      }

                      if (username.isEmpty) {
                        setState(() {
                          _errorText = 'Name';
                        });
                        return;
                      }

                      if (password.isEmpty) {
                        setState(() {
                          _errorText = 'Pass';
                        });
                        return;
                      }

                      // Clear the error message
                      setState(() {
                        _errorText = '';
                      });
                      authenticate(username,password);
                    },
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15), // Set the desired border radius here
                        ),
                      ),
                      backgroundColor: MaterialStateProperty.all<Color>(Color(0xFF048293)), // Set the button background color here
                    ),
                    child: Text(
                      'Login',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,),
                    ),
                  ),
                ),
                // Container(
                //   margin: EdgeInsets.only(top: 13),
                //   alignment: Alignment.bottomRight,
                //   child: GestureDetector(
                //       onTap: () {
                //         Navigator.push(
                //           context,
                //           MaterialPageRoute(
                //             builder: (context) => Forgot(),
                //           ),
                //         );
                //       },
                //       child: Text(
                //         "Forgot Password?",
                //         style: TextStyle(
                //           fontSize: 14,
                //           color: Color(0xFF005460),
                //         ),
                //       ),
                //   ),
                // ),
                SizedBox(height: 10,),
                Visibility(
                  visible: _isLoading,
                  child: Container(
                    color: Colors.transparent,
                    child: Center(
                      child: Loader(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
      );
  }
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