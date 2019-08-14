import 'dart:async';
import 'package:meta/meta.dart';

abstract class BlocBase<T> {

  StreamController<T> _controller = StreamController<T>.broadcast();

  StreamSink<T> get inSink => _controller.sink;

  Stream<T> get stream => _controller.stream;

  @mustCallSuper
  void dispose() {
    _controller.close();
  }

}