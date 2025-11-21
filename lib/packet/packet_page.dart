import 'dart:async';

import 'package:flutter/material.dart';

import '../auth/user.dart';

class PacketPage extends StatefulWidget {
  static const String request = "perform action";
  const PacketPage({required this.user, super.key});
  final User user;

  @override
  State<PacketPage> createState() => _PacketPageState();
}

class _PacketPageState extends State<PacketPage> {
  late final Timer timer;
  final actionpassTEC = TextEditingController();

  StreamSubscription? errStreamSub;
  String? actionError;

  void onErrorRecieved(dynamic data){
    setState(() {
      actionError = data;
    });
  }

  @override
  void initState() {
    timer = Timer.periodic(Duration(milliseconds: 50), (t) => setState((){}));
    errStreamSub = widget.user.getRW().getRequestErrorStream(PacketPage.request).listen(onErrorRecieved);
    super.initState();
  }
  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void submit(){
    widget.user.getRW().send("perform action", {
      "pass": actionpassTEC.text,
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: (){
                Navigator.of(context).pop();
                widget.user.removePacket();
              },
              child: Text("quit")
            )
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(child: SizedBox()),
                  Text(widget.user.packet!.title, style: TextStyle(fontSize: 25),),
                  SizedBox(height: 34,),
                  if (widget.user.packet!.difference().inDays > 0)
                    Text("${widget.user.packet!.difference().inDays} days and", style: TextStyle(fontSize: 17),),
                  SizedBox(height: 3,),
                  Text(widget.user.packet!.timeTo(), style: TextStyle(fontSize: 19),),
                  Expanded(child: SizedBox()),
                  Text("enter an action code:"),
                  SizedBox(
                    width: 200,
                    child: TextField(
                      controller: actionpassTEC,
                      obscureText: true,
                      decoration: InputDecoration(
                        errorText: actionError,
                        errorMaxLines: 3,
                      ),
                      onSubmitted: (e) => submit(),
                    ),
                  ),
                  TextButton(
                    onPressed: submit,
                    child: Text("perform the action"),
                  ),
                  SizedBox(height: 24,),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
