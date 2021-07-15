import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      home: MyMain(),
    ),
  );
}

class MyMain extends StatefulWidget {
  const MyMain({Key? key}) : super(key: key);

  @override
  _MyMainState createState() => _MyMainState();
}

class _MyMainState extends State<MyMain> {

  double dx = 0, dy = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: GestureDetector(
            onPanUpdate: (data) {
              setState(() {
                dx = data.globalPosition.dx;
                dy = data.globalPosition.dy;
                print("dx: ${dx} dy: ${dy}");
              });
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                Positioned(
                  left: dx,
                  top: dy,
                  child: CircleAvatar(
                    child: Container(),
                    radius: 10,
                    backgroundColor: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
