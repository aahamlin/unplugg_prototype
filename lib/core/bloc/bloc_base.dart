import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

abstract class BlocBase<T> {

  StreamController<T> _controller = StreamController<T>.broadcast();

  StreamSink<T> get _inSink => _controller.sink;

  Stream<T> get stream => _controller.stream;

  T _state;
  T get currentState => _state;

  void add(T t) {
    _state = t;
    _inSink.add(t);
  }


  @mustCallSuper
  void dispose() {
    _controller.close();
  }

}