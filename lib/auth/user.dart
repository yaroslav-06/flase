import 'package:flase/packet/packet.dart';
import 'package:flase/packet/packet_creator.dart';

import '../readwriter/readwriter.dart';

class User {
  final RW _rw;
  String? username;
  Packet? packet;
  bool loggedIn = false;
  bool showPacket = false;
  PacketCreatorInfo? packetInfo;
  bool _newPacketHandlerRunning = false, _creatingPacket = false;

  User(RW rw) : _rw = rw;

  bool isLoggedIn() {
    return username != null;
  }
  bool isPacketOpenned(){
    return showPacket;
  }
  bool creatingPacket(){
    return _creatingPacket;
  }

  void deselectCreatingPacket(){
    _creatingPacket = false;
  }

  RW getRW() {
    return _rw;
  }

  void login(String usrn, String pass) {
    _rw.send("login", {
      "username": usrn,
      "password": pass,
    });
    _rw.getRequestStream('auth')
      .firstWhere((val) => val.isSuccessful())
      .then((val) {
        username = usrn;
        _rw.pageUpdate();
    });
  }

  void logout() {
    username = null;
    _rw.send("logout", {});
    _rw.getRequestStream('auth')
      .firstWhere((val) => val.isSuccessful())
      .then((val) {
        _rw.pageUpdate();
    });
  }

  void removePacket(){
    showPacket = false;
    print("remove packet");
    // print("is packet opened: $showPacket");
    _rw.pageUpdate();
  }

  void handleNewPacket() {
    _newPacketHandlerRunning = true;
    _rw.getRequestDataStream('packet').listen((val){
      packet = Packet.fromJSON(val, onDestruct: removePacket);
      if (packet!.isDestructed()){
        showPacket = false;
      }else{
        showPacket = true;
      } 
      _rw.pageUpdate();
    });
  }

  void getPacket(String pass) {
    _rw.send("get packet", {
      "pass": pass,
    });

    if (!_newPacketHandlerRunning) handleNewPacket();
  }

  void createPacket(Map<String, dynamic> packetData){
    _rw.send("packet creator", packetData);
    _rw.getRequestStream("packet creator").listen((val) => print("req stream: $val"));
  }

  void requestPacketCreation(String name) {
    _creatingPacket = true;
    packetInfo = PacketCreatorInfo(packetName: name);
    _rw.pageUpdate();
  }
}
