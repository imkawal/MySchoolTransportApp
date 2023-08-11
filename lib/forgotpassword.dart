import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';


class Forgot extends StatefulWidget {
  @override
  _Forgot createState() => _Forgot();
}

class _Forgot extends State<Forgot> with SingleTickerProviderStateMixin {
  TextEditingController _mailController = TextEditingController();
  String _errorText = '';

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double gapHeight = screenHeight * 0.18;

    void _sendMail() async {
      String username = 'kawal.levnext@gmail.com'; // Replace with your email address
      String password = '2251280794'; // Replace with your email password or app password if enabled

      final smtpServer = gmail(username, password);

      final message = Message()
        ..from = Address(username, 'Your Name') // Replace with your name
        ..recipients.add('singhkawal2112@gmail.com') // Replace with the recipient's email address
        ..subject = 'Test Email'
        ..text = 'This is a test email sent from Flutter.';

      try {
        final sendReport = await send(message, smtpServer);
        print('Message sent:');
      } catch (e) {
        print('Error sending email: $e');
      }
    }

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
                    "Forgot",
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
                      "If you  need help to reset your password, we can help you by sending a link to reset it",
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
                    controller: _mailController,
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide(
                          color: _errorText == 'Email' ? Colors.red : Color(0xFF999999),
                          width: 2.0,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          color:  _errorText == 'Email' ? Colors.red : Color(0xFF999999), // Change this to the desired enabled border color
                          width: 2.0,
                        ),
                      ),
                      prefixIcon: Icon(
                        Icons.mail_outline,
                        color: Color(0xFF005460),
                      ),
                      hintText: "Email ID",
                      hintStyle: TextStyle(
                        color: Color(0xFF005460),
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ),
                AnimatedSwitcher(
                  duration: Duration(milliseconds: 200),
                  child: _errorText == 'Email'
                      ? Container(
                    key: Key('error-container'),
                    margin: EdgeInsets.only(top: 5, left: 10),
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      "Please Enter MailID",
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
                      String email = _mailController.text.trim();

                      if(email.isEmpty){
                        setState(() {
                          _errorText = 'Email';
                        });
                        return;
                      }

                      setState(() {
                          _errorText = '';
                      });

                      _sendMail();
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
                      'Send',
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