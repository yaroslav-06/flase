class Packet {
  late String title;
  late DateTime deliveryTime;
  Function? _onDestruct;
  bool _destructed = false;
  Packet.fromJSON(dynamic val, {Function? onDestruct})
  {
    var temp = val as Map<String, dynamic>;
    title = temp['title'];
    var dtstr = temp['deliveryTime'];
    deliveryTime = DateTime.parse(dtstr+"z").toUtc();
    difference();
    _onDestruct = onDestruct;
  }

  bool isDestructed(){
    return _destructed;
  }

  Duration difference(){
      var diff = deliveryTime.difference(DateTime.now());
      if (diff < Duration.zero && !_destructed){
        _destructed = true;
        if(_onDestruct != null) _onDestruct!();
        return diff;
      }
      return deliveryTime.difference(DateTime.now());
  }

  String timeTo(){
      final diff = difference();
      final hours = diff.inHours % 24, mins = diff.inMinutes % 60,
            secs = diff.inSeconds % 60, milisecs = diff.inMilliseconds % 1000;
      final timeTo = "${hours.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}.${(milisecs ~/ 100).toString().padLeft(1, '0')}";
    return timeTo;
  }

  String displayRemainingTime(){
    final days = difference().inDays;
    return "$days days and ${timeTo()}";
  }

  @override
    String toString() {
      return "packet{ title = $title, will execute in ${displayRemainingTime()} }";
    }
}
