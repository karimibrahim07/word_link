import 'dart:async';

class GameTimer {
  late Timer _timer;
  late final Function(int) _onTick;

  GameTimer(this._onTick);

  void start(int durationInSeconds) {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _onTick(durationInSeconds);
      if (durationInSeconds > 0) {
        durationInSeconds--;
      } else {
        _timer.cancel();
      }
    });
  }

  void stop() {
    _timer.cancel();
  }
}
