import 'package:flase/packet/packet_creator.dart';
import 'package:flase/packet/packet_page.dart';
import 'package:flase/packet/packet_selector.dart';
import 'package:flase/pages/error_page.dart';
import 'package:flutter/material.dart';

import 'auth/user.dart';
import 'readwriter/readwriter.dart';
import 'auth/login.dart';

void main() {
  // RW rw = RW('ws://localhost:14539');
  // RW rw = RW('ws://10.232.211.118:14539');
  RW rw = RW('ws://45.55.80.161:14539');
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
  Widget build(BuildContext context) {
    widget.user.setPageUpdate(()=>setState((){print("main page update");}));
    return FutureBuilder(
      future: widget.rw.ready,
      builder: (context, snapshot) {
        if(!snapshot.hasData || snapshot.data == null){
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if(!snapshot.data!){
          return ErrorPage(errorMessage: "couldn't connect to the server");
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
                child: PacketCreator(
                  user: widget.user,
                )
              ),
          ],
          onDidRemovePage: (page) {},
        );
      }
    );
  }
}
