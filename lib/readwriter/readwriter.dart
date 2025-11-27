import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:web_socket_channel/web_socket_channel.dart';

class Request {
  static const String successCode = "200";
  static const String errorCode = "406";

  dynamic data, error;
  String requestType, status;
  Request.fromMap(Map<String, dynamic> val):
    data = val['data'], error = val['error'],
    requestType = val['request'], status = val['status'];
  @override
  String toString(){
    return "{data: $data, error: $error, reqType: $requestType, status: $status}";
  }
  bool isError(){
    return status == errorCode;
  }
  bool isSuccessful(){
    return status == successCode;
  }
}

StreamTransformer<dynamic, Map<String, dynamic>> toMapDynamic
= StreamTransformer<dynamic, Map<String, dynamic>>.fromHandlers(handleData: (val, sink){
  final data = jsonDecode(val);
  sink.add(data as Map<String, dynamic>);
});

StreamTransformer<Map<String, dynamic>, Request> toRequest
  = StreamTransformer<Map<String, dynamic>, Request>.fromHandlers(handleData: (val, sink){
  sink.add(Request.fromMap(val));
});

StreamTransformer<Map<String, dynamic>, dynamic> getMapField(String field){
  return StreamTransformer<Map<String, dynamic>, dynamic>.fromHandlers(handleData: (val, sink){
    sink.add(val[field]);
  });
}

StreamTransformer<Request, dynamic> getData = StreamTransformer.fromHandlers(handleData: (val, sink){
  sink.add(val.data);
});

StreamTransformer<Request, dynamic> getError = StreamTransformer.fromHandlers(handleData: (val, sink){
  sink.add(val.error);
});

class RW {
  late WebSocketChannel _ws;
  late String? _url;
  late Future<bool> ready;
  late StreamSplitter<Request> _requestSplitter, _dataSplitter, _errorSplitter;
  late Stream<Request> _errorMessages, _data;
  Timer? _checkConn;
  Function pageUpdate = (){};
  StreamSubscription<dynamic>? connErrorStream;


  void setUrl(String url) => _url = url;
  void resetUrl() => _url = null;
  String? getUrl() => _url;

  void setPageUpdate(Function pageUpd){
    pageUpdate = pageUpd;
  }

  _onData(Request data) {
    print("data: ${data.data}, rq: ${data.error}, ${data.requestType}");
  }
  _onError(Request data) {
    print("error: ${data.error}");
  }

  Stream<dynamic> getRequestDataStream(String request){
    return _dataSplitter.split()
      .where((val) => val.requestType == request)
      .transform(getData).asBroadcastStream();
  }

  Stream<dynamic> getRequestErrorStream(String request){
    return _errorSplitter.split()
      .where((val) => val.requestType == request)
      .transform(getError).asBroadcastStream();
  }

  Stream<Request> getRequestStream(String request){
    return _requestSplitter.split()
      .where((val) => val.requestType == request).asBroadcastStream();
  }

  void _streamErrorHandling(dynamic err){
    print("closed: $err");
    reconnect();
    pageUpdate();
  }

  RW(String url) {
    setUrl(url);
    reconnect();
  }

  send(String req, dynamic data) async {
    return _ws.sink.add(jsonEncode({"r": req, "d": data}));
  }

  void dispose(){
    _ws.sink.close();
    if(_checkConn!=null) _checkConn!.cancel();
  }

  void reconnect() {
    if(connErrorStream!=null){connErrorStream!.cancel();} 
    if(_checkConn!=null) _checkConn!.cancel();

    _ws = WebSocketChannel.connect(Uri.parse(_url!));
    ready = Future<bool>(() async {
      try {
        await _ws.ready;
      } on SocketException catch (_) {
        print("socket exception");
        return false;
      } on WebSocketChannelException catch (e) {
        print("websocket chan exception");
        print(e);
        return false;
      }
      _checkConn = Timer.periodic(Duration(seconds: 1), (_){
        if(_ws.closeReason != null) _streamErrorHandling(_ws.closeReason);
      });
      _requestSplitter = StreamSplitter(_ws.stream.transform(toMapDynamic).transform(toRequest));
      _errorMessages = _requestSplitter.split()
        .where((val) => val.isError()).asBroadcastStream();
      _data = _requestSplitter.split()
        .where((val) => val.isSuccessful()).asBroadcastStream();

      _data.listen(_onData);
      _errorMessages.listen(_onError);

      _dataSplitter = StreamSplitter(_data);
      _errorSplitter = StreamSplitter(_errorMessages);
      //
      return true;
    });
  }
}
