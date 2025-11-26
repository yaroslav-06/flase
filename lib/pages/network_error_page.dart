import 'package:flase/pages/error_page.dart';
import 'package:flase/readwriter/readwriter.dart';
import 'package:flutter/material.dart';

class NetworkErrorPage extends StatelessWidget {
  const NetworkErrorPage({super.key, required this.rw});
  final RW rw;

  @override
  Widget build(BuildContext context) {
    return ErrorPage(
      rw: rw,
      errorMessage: "couldn't connect to the server at ${rw.getUrl()}",
      action: TextButton(
        child: Text("reconnect"),
        onPressed: (){
          rw.reconnect();
          rw.pageUpdate();
        },
      ),
    );
  }
}
