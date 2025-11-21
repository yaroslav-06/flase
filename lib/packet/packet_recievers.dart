import 'package:flutter/material.dart';

class RecieverAdder extends StatefulWidget {
  const RecieverAdder({super.key, required this.save});

  final Function(Map<String, dynamic>) save;

  @override
  State<RecieverAdder> createState() => _RecieverAdderState();
}

class _RecieverAdderState extends State<RecieverAdder> {

  String selectedType = "telegram";
  Map<String, dynamic> recieverJson = {"type": "telegram"};
  late Map<String, Widget> recievers;

  Widget __emailReciever(){
    return TextField(
      decoration: InputDecoration(
        labelText: "email"
      ),
      onChanged: (txt){
        recieverJson["email"] = txt;
      },
    );
  }

  Widget __telegramReciever(){
    return TextField(
      decoration: InputDecoration(
        labelText: "telegram username (starting with @)"
      ),
      onChanged: (txt){
        recieverJson["username"] = txt;
      },
    );
  }

  @override
  void initState() {
    recievers  = {
      "telegram": __telegramReciever(),
      "email": __emailReciever(),
    };
    super.initState();
  }
  Widget __messageSelector(){
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(6),
      child: SizedBox(
        width: 200,
        child: TextField(
          decoration: InputDecoration(
            labelText: "message to send:",
          ),
          onChanged: (txt){
            recieverJson["message"] = txt;
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 300,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("choose reciever type: "),
                  DropdownButton(
                    value: selectedType,
                    items: recievers.keys.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                    onChanged: (v) {
                      recieverJson['type'] = v;
                      setState(() => selectedType = v!);
                    }
                  ),
                ],
              ),
              __messageSelector(),
              recievers[selectedType]!,
              TextButton(
                onPressed: () {
                  widget.save(recieverJson);
                  Navigator.pop(context);
                },
                child: Text("save reciever")
              )
            ],
          ),
        ),
      ),
    );
  }
}
