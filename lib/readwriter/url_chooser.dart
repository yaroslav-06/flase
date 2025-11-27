import 'package:flase/readwriter/readwriter.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UrlChooser extends StatelessWidget {
  const UrlChooser({super.key, required this.rw});

  final RW rw;

  @override
  Widget build(BuildContext context) {
    TextEditingController ctrl = TextEditingController(text: rw.getUrl());
    Future<void> save() async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      print("saving0: ${ctrl.text}");
      await prefs.setString('url', ctrl.text);
      print("saving: ${ctrl.text}");
      rw.setUrl(ctrl.text);
      rw.reconnect();
      rw.pageUpdate();
    }
    return Center(
      child: Column(
        children: [
          Text("enter server url or ip (for example: ws://0.0.0.0:14539)"),
          TextField(
            controller: ctrl,
            onSubmitted: (_) => save(),
          ),
          TextButton(
            onPressed: () async {
              print("hr");
              await save();
            },
            child: Text("save"),
          ),
        ],
      ),
    );
  }
}
