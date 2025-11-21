import 'package:flase/packet/packet_actions.dart';
import 'package:flase/packet/packet_recievers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../auth/user.dart';

class PacketCreatorInfo {
  static const String request = "create packet";
  String? packetName;
  PacketCreatorInfo({this.packetName});
}

class PacketCreator extends StatefulWidget {
  const PacketCreator({required this.user, super.key});
  final User user;

  @override
  State<PacketCreator> createState() => _PacketCreatorState();
}

class _PacketCreatorState extends State<PacketCreator> {
  TextEditingController nameTEC = TextEditingController();
  late TextEditingController passTEC;
  late DateTime dateTime;
  String? err, accepted;
  @override
  void initState() {
    passTEC = TextEditingController(text: widget.user.packetInfo?.packetName ?? "");
    dateTime = DateTime.now();
    widget.user.getRW().getRequestErrorStream("packet creator").listen((dt){
      setState(() {
              err = dt;
            });
    });
    widget.user.getRW().getRequestDataStream("packet creator").listen((dt){
      setState(() {
          err = null;
          accepted = dt;
            });
    });
    super.initState();
  }
  Widget __nameChooser(){
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(6),
      child: SizedBox(
        width: 200,
        child: TextField(
          controller: nameTEC,
          decoration: InputDecoration(
            labelText: "name",
          ),
        ),
      ),
    );
  }
  Widget __passChooser(){
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(6),
      child: SizedBox(
        width: 200,
        child: TextField(
          controller: passTEC,
          decoration: InputDecoration(
            errorText: err,
            labelText: "access pass",
          ),
        ),
      ),
    );
  }
  Widget __dateChooser(){
    final chsr = SizedBox(
      height: 150,
      child: CupertinoDatePicker(
        initialDateTime: dateTime,
        dateOrder: DatePickerDateOrder.dmy,
        mode: CupertinoDatePickerMode.date,
        use24hFormat: true,
        onDateTimeChanged: (dt) {
          setState(() {
            dateTime = dt.copyWith(hour: dateTime.hour,
                                   minute: dateTime.minute,
                                   second: dateTime.second);});
          print(dateTime.toString());
        }
      ),
    );
    return Center(
      child: SizedBox(
        width: 100,
        height: 40,
        child: TextButton(
          onPressed: () => showDialog(context: context, builder: (ctx) => chsr),
          child: Text("${dateTime.day}/${dateTime.month}/${dateTime.year}")
        ),
      ),
    );
  }
  Widget __timeChooser(){
    final chsr = SizedBox(
      height: 150,
      child: CupertinoDatePicker(
        initialDateTime: dateTime,
        mode: CupertinoDatePickerMode.time,
        use24hFormat: true,
        showTimeSeparator: true,
        onDateTimeChanged: (dt) {
          setState(() {
            dateTime = dt;
                    });
          print(dateTime.toString());
        }
      ),
    );
    return Center(
      child: SizedBox(
        width: 100,
        height: 40,
        child: TextButton(
          onPressed: () => showDialog(context: context, builder: (ctx) => chsr),
          child: Text("${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}")
        ),
      ),
    );
  }

  List<dynamic> actions = [];
  List<dynamic> recievers = [];

  Widget __addAction(){
    return Center(
      child: SizedBox(
        width: 100,
        height: 40,
        child: TextButton(
          onPressed: () => showDialog(context: context,
            builder: (ctx) => ActionAdder(
              save: (actionJson) {
                setState(() {
                  actions.add(actionJson);
                                });
              },
            )),
          child: Text("add action")
        ),
      ),
    );
  }

  Widget __addReciever(){
    return Center(
      child: SizedBox(
        width: 150,
        height: 40,
        child: TextButton(
          onPressed: () => showDialog(context: context,
            builder: (ctx) => RecieverAdder(
              save: (rsvJson) {
                setState(() {
                  recievers.add(rsvJson);
                                });
              },
            )),
          child: Text("add reciever")
        ),
      ),
    );
  }

  Widget __listRecievers(){
    return Center(
      child: Container(
        padding: const EdgeInsets.all(6),
        width: 100,
        child: Text("recievers: $recievers"),
      ),
    );
  }

  Widget __listActions(){
    return Center(
      child: Container(
        padding: const EdgeInsets.all(6),
        width: 100,
        child: Text("actions: $actions"),
      ),
    );
  }

  Widget __sendButton(){
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 30),
        width: 100,
        height: 30,
        child: TextButton(
          style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Theme.of(context).primaryColor)),
          onPressed: () async {
            print(dateTime.toUtc().toIso8601String());
            Map<String, dynamic> finalMap = {
              "name": nameTEC.text,
              "deliveryTime": dateTime.toUtc().toIso8601String(),
              "pass": passTEC.text,
              "actions": actions,
              "recievers": recievers,
            };
            print(finalMap);
            widget.user.createPacket(finalMap);
          },
          child: Text("send", style: TextStyle(color: Colors.white),)
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(widget.user.packetInfo != null);
    return Scaffold(
      body: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () {
                widget.user.deselectCreatingPacket();
                Navigator.pop(context);
              },
              child: Text("back")
            ),
          ),
          Expanded(
            child: ListView(
              shrinkWrap: true,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height / 2.7,),
                __nameChooser(),
                __passChooser(),
                __timeChooser(),
                __dateChooser(),
                __listActions(),
                __addAction(),
                __listRecievers(),
                __addReciever(),
                __sendButton(),
                if (accepted != null) Center(child: Icon(Icons.check)),
                SizedBox(height: MediaQuery.of(context).size.height / 4,),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
