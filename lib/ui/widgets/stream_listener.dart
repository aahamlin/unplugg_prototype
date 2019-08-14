import 'dart:async';
import 'package:flutter/material.dart';

typedef BlocWidgetListener = Function(dynamic);

class StreamListener<T> extends StatefulWidget {

  final Stream<T> stream;
  final Function(dynamic) listener;
  final Widget child;

  StreamListener({Key key,
    @required Stream<T> this.stream,
    @required BlocWidgetListener this.listener,
    @required Widget this.child}) : super(key: key);

  @override
  _StreamListenerState createState() => _StreamListenerState();
}

class _StreamListenerState<T> extends State<StreamListener<T>> {

  StreamSubscription<T> _subscription;

  @override
  void initState() {
    super.initState();
    _subscribe();
  }

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }


  @override
  void didUpdateWidget(StreamListener oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stream != widget.stream) {
      _subscribe();
    }
  }


  @override
  Widget build(BuildContext context) {
    return widget.child;
  }


  _subscribe() {
    _subscription = widget.stream.listen(widget.listener);
  }

  _unsubscribe() {
    if (_subscription != null) {
      _subscription.cancel();
      _subscription = null;
    }
  }

}