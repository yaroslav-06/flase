import 'package:flase/packet/packet_creator.dart';
import 'package:flase/packet/packet_page.dart';
import 'package:flase/packet/packet_selector.dart';
import 'package:flase/pages/error_page.dart';
import 'package:flase/pages/network_error_page.dart';
import 'package:flase/readwriter/url_chooser.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth/user.dart';
import 'readwriter/readwriter.dart';
import 'auth/login.dart';

void main() async {
  String? url = await SharedPreferencesAsync().getString("url");
  RW rw = RW(url ?? "ws://localhost:14539");
  runApp(MyApp(rw));
}

class MyApp extends StatelessWidget {
  final RW rw;
  const MyApp(this.rw, {super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: SafeArea(child: MyNavigator(rw)),
    );
  }
}

class MyNavigator extends StatefulWidget {
  MyNavigator(this.rw, {super.key}): user = User(rw);
  final User user;
  final RW rw;

  @override
  State<MyNavigator> createState() => _MyNavigatorState();
}

class _MyNavigatorState extends State<MyNavigator> {
  @override
  void dispose() {
    widget.rw.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    widget.rw.setPageUpdate(()=>setState((){print("main page update");}));
    if(widget.rw.getUrl() == null){
      return Material(
        child: UrlChooser(rw: widget.rw)
      );
    }
    return FutureBuilder(
      future: widget.rw.ready,
      builder: (context, snapshot) {
        if(!snapshot.hasData || snapshot.data == null){
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if(!snapshot.data!){
          return NetworkErrorPage(rw: widget.rw);
        }
        return Navigator(
          pages: [
            MaterialPage(
              key: ValueKey("loginPage"),
              child: LoginPage(user: widget.user)),

            if (widget.user.isLoggedIn())
              MaterialPage(
                key: ValueKey("package selector page"),
                child: PacketSelector(user: widget.user),
              ),

            if (widget.user.isPacketOpenned())
              MaterialPage(
                key: ValueKey("packet page"),
                child: PacketPage(
                  user: widget.user,
                )
              ),
            if (widget.user.creatingPacket())
              MaterialPage(
                key: ValueKey("packet creation"),
                child: PacketCreator(user: widget.user,)
              ),
          ],
          onDidRemovePage: (page) {},
        );
      }
    );
  }
}
