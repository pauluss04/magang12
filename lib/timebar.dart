import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomProgressBar extends StatelessWidget {
  final double width;
  final int value;
  final int totalValue;
  CustomProgressBar(this.width, this.value, this.totalValue);
  @override
  Widget build(BuildContext context) {
    double ratio = value / totalValue;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(
          Icons.timer,
          color: Colors.white,
        ),
        SizedBox(width: 10),
        Stack(
          children: <Widget>[
            Container(
              width: width,
              height: 10,
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(5)),
            ),
            Material(
              borderRadius: BorderRadius.circular(5),
              elevation: 3,
              child: AnimatedContainer(
                height: 10,
                width: width * ratio,
                duration: Duration(milliseconds: 500),
                decoration: BoxDecoration(
                    color: (ratio < 0.3
                        ? Colors.red
                        : (ratio < 0.6 ? Colors.amber : Colors.lightGreen)),
                    borderRadius: BorderRadius.circular(5)),
              ),
            )
          ],
        )
      ],
    );
  }
}

class TimeState with ChangeNotifier {
  int _time;
  TimeState(this._time);
  int get time => _time;
  set time(int newTime) {
    _time = newTime;
    notifyListeners();
  }
}
