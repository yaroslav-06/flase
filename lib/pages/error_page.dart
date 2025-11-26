import 'package:flase/readwriter/readwriter.dart';
import 'package:flutter/material.dart';

class ErrorPage extends StatelessWidget {
  const ErrorPage({super.key, required this.errorMessage, this.action, required this.rw});
  final RW rw;
  final String errorMessage;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: TextButton(
              onPressed: (){
                rw.resetUrl();
                rw.pageUpdate();
              },
              child: Text("change url")
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("recieved unexpected fatal error:"),
                  Text(errorMessage),
                  if(action!=null) action!
                ],
              ),
            ),
          ),
        ],
      )
    );
  }
}
