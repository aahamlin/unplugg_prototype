import 'package:flutter/material.dart';
import 'package:unplugg_prototype/core/shared/utilities.dart';

class TimerText extends StatelessWidget {
  final Duration duration;
  TimerText({Key key, Duration this.duration}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(TimerTextFormatter.format(duration),
        style: Theme.of(context).textTheme.display1
            .merge(TextStyle(color: Colors.grey[300]))
    );
  }
}
