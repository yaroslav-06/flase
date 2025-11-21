import 'package:flutter/material.dart';

import 'user.dart';

class LoginPage extends StatefulWidget {
  static const request = "auth";

  const LoginPage({required this.user, super.key});

  final User user;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? err;
  final TextEditingController usernameTEC = TextEditingController(),
                              passTEC = TextEditingController();

  void onErrorRecieved(dynamic error) {
    setState(() {
      print("recieved error");
      err = error;
    });
  }

  void submit(){
    widget.user.login(usernameTEC.text, passTEC.text);
  }

  @override
  void initState() {
    widget.user.getRW().getRequestErrorStream(LoginPage.request).listen(onErrorRecieved);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 200,
              child: TextField(
                controller: usernameTEC,
                decoration: InputDecoration(
                  hintText: "username",
                ),
              ),
            ),
            SizedBox(
              width: 200,
              child: TextField(
                controller: passTEC,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: "password",
                  errorText: err,
                  errorMaxLines: 3,
                ),
                onSubmitted: (e) => submit(),
              ),
            ),
            TextButton(
              onPressed: submit,
              child: Text("login"),
            )
        ]),
      ),
    );
  }
}
