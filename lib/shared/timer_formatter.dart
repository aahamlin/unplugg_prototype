
class TimerTextFormatter {
  static String format(Duration duration) {
    assert(duration != null);
    int hours = duration.inHours;
    int minutes = duration.inMinutes;
    int seconds = duration.inSeconds;

    String hoursStr = (hours % 24).toString().padLeft(1, '0');
    String minutesStr = (minutes % 60).toString().padLeft(2, '0');
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');

    return "$hoursStr.$minutesStr:$secondsStr";
  }

  static String formatMinSec(Duration duration) {
    assert(duration != null);
    int minutes = duration.inMinutes;
    int seconds = duration.inSeconds;

    String minutesStr = (minutes).toString().padLeft(2, '0');
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');

    return "$minutesStr:$secondsStr";
  }
}