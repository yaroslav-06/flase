import 'package:flutter/material.dart';

class ActionAdder extends StatefulWidget {
  const ActionAdder({super.key, required this.save});

  final Function(Map<String, dynamic>) save;

  @override
  State<ActionAdder> createState() => _ActionAdderState();
}

class _ActionAdderState extends State<ActionAdder> {

  Map<String, dynamic> actionJson = {"type": "delete"};

  Widget __timeChangerAction(){
    return TextField(
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: "duration in minutes to subtract"
      ),
      onChanged: (txt){
        actionJson["duration"] = int.parse(txt);
      },
    );
  }

  @override
  void initState() {
    actions  = {
      "delete": DeleteAction(),
      "time changer": __timeChangerAction(),
    };
    super.initState();
  }

  late Map<String, Widget> actions;
  String selectedAction = "delete";
  Widget __passChooser(){
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(6),
      child: SizedBox(
        width: 200,
        child: TextField(
          decoration: InputDecoration(
            labelText: "action pass",
          ),
          onChanged: (txt){
            actionJson["pass"] = txt;
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
                  Text("choose action: "),
                  DropdownButton(
                    value: selectedAction,
                    items: actions.keys.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                    onChanged: (v) {
                      actionJson['type'] = v;
                      setState(() => selectedAction = v!);
                    }
                  ),
                ],
              ),
              __passChooser(),
              actions[selectedAction]!,
              TextButton(
                onPressed: () {
                  widget.save(actionJson);
                  Navigator.pop(context);
                },
                child: Text("save action")
              )
            ],
          ),
        ),
      ),
    );
  }
}

class DeleteAction extends StatelessWidget {
  const DeleteAction({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox();
  }
}
