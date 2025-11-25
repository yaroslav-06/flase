import 'dart:async';

import 'package:flutter/material.dart';

import '../auth/user.dart';

class PacketSelector extends StatefulWidget {
  static const String request = "get packet";
  const PacketSelector({required this.user, super.key});
  final User user;

  @override
  State<PacketSelector> createState() => _PacketSelectorState();
}

class _PacketSelectorState extends State<PacketSelector> {

  final passTEC = TextEditingController();

  StreamSubscription? errStreamSub;
  String? err;

  void onErrorRecieved(dynamic error) {
    err = error;
    setState(() {
      print("recieved error");
      err = error;
    });
  }

  void submit(){
    widget.user.getPacket(passTEC.text);
  }

  void create(){
    widget.user.requestPacketCreation(passTEC.text);
  }

  @override
  void initState() {
    errStreamSub = widget.user.getRW().getRequestErrorStream(PacketSelector.request).listen(onErrorRecieved);
    super.initState();
  }

  @override
  void dispose() {
    if (errStreamSub != null) errStreamSub!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () {
                widget.user.logout();
                Navigator.of(context);
              },
              child: Text("quit")
            )
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("enter package passcode:"),
                  SizedBox(
                    width: 200,
                    child: TextField(
                      controller: passTEC,
                      obscureText: true,
                      decoration: InputDecoration(
                        errorText: err,
                        errorMaxLines: 3,
                      ),
                      onSubmitted: (e) => submit(),
                    ),
                  ),
                  TextButton(
                    onPressed: submit,
                    child: Text("get package"),
                  ),
                  TextButton(
                    onPressed: create,
                    child: Text("create package"),
                  ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
