import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unplugg_prototype/core/bloc/bloc_base.dart';
import 'package:unplugg_prototype/core/shared/log_manager.dart';

typedef BlocWidgetListener = Function(BuildContext, dynamic);

class BlocListener<B extends BlocBase<T>, T> extends StatefulWidget {

  final B bloc;
  final BlocWidgetListener listener;
  final Widget child;

  BlocListener({Key key,
    @required this.bloc,
    @required this.listener,
    @required this.child}) : super(key: key);

  @override
  _BlocListenerState createState() => _BlocListenerState();
}

class _BlocListenerState<B extends BlocBase<T>, T>
    extends State<BlocListener<B, T>> {

  Logger _logger;
  StreamSubscription<T> _subscription;
  T _previousState;
  B _bloc;

  @override
  void initState() {
    super.initState();
    _logger = LogManager.getLogger('BlocListener');
    _bloc = widget.bloc ?? Provider.of<B>(context);
    _previousState = _bloc?.currentState;
    _subscribe();
  }

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }


  @override
  void didUpdateWidget(BlocListener oldWidget) {
    super.didUpdateWidget(oldWidget);
    final Stream<T> oldStream =
        oldWidget.bloc?.stream ?? Provider.of<B>(context).stream;
    final Stream<T> currentStream = widget.bloc?.stream ?? oldStream;
    if (oldStream != currentStream) {
      _logger.d('oldStream != currentStream');
      if (_subscription != null) {
        _unsubscribe();
        _bloc = widget.bloc ?? Provider.of<B>(context);
        _previousState = _bloc?.currentState;
      }
      _subscribe();
    }
  }


  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  _subscribe() {
    if (_bloc?.stream != null) {
      _subscription = _bloc.stream.listen((T event) {
        // todo: add conditional compare values?
        _logger.d('notifying listeners of $event');
        widget.listener(context, event);
        _previousState = event;
      });
      _logger.d('subscribed');
    }
  }

  _unsubscribe() {
    if (_subscription != null) {
      _subscription.cancel();
      _logger.d('unsubscribed');
      _subscription = null;
    }
  }

}