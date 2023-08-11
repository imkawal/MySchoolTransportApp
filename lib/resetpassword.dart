import 'package:flutter/material.dart';
import 'forgotpassword.dart';

class ResetPass extends StatefulWidget {
  @override
  _ResetPass createState() => _ResetPass();
}

class _ResetPass extends State<ResetPass> with SingleTickerProviderStateMixin {
  bool _firstobscureText = true;
  bool _secondobscureText = true;
  TextEditingController _firstpassController = TextEditingController();
  TextEditingController _secondpassontroller = TextEditingController();
  String _errorText = '';

  void _submit() {
      String first = _firstpassController.text.trim();
      String second = _secondpassontroller.text.trim();
      if(first == second){
          setState(() {
              _errorText = '';
          });
      }else{
        setState(() {
             _errorText = '1';
        });
      }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double gapHeight = screenHeight * 0.18;

    return Scaffold(
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
                    "Create New",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 38,
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    "Password?",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 36,
                    ),
                  ),
                ),
                SizedBox(height: gapHeight),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 1),
                    child: Text(
                      "Your password must be different from previusly used one.",
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
                    controller: _firstpassController,
                    obscureText: _firstobscureText,
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
                        icon: Icon(_firstobscureText
                            ? Icons.visibility_off_sharp
                            : Icons.visibility),
                        onPressed: () {
                          setState(() {
                            _firstobscureText = !_firstobscureText;
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
                  child: _errorText == '1'
                      ? Container(
                    key: Key('error-container'),
                    margin: EdgeInsets.only(top: 5, left: 10),
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      "Please Enter Same Password.",
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
                    controller: _secondpassontroller,
                    obscureText: _secondobscureText,
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
                        icon: Icon(_secondobscureText
                            ? Icons.visibility_off_sharp
                            : Icons.visibility),
                        onPressed: () {
                          setState(() {
                            _secondobscureText = !_secondobscureText;
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
                  child: _errorText == '1'
                      ? Container(
                    key: Key('error-container'),
                    margin: EdgeInsets.only(top: 5, left: 10),
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      "Please Enter Same Password.",
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
                       return _submit();
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
                      'Submit',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}