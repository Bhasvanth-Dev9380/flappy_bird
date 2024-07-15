import 'dart:async';

import 'package:flappy_bird/barrier.dart';
import 'package:flappy_bird/bird.dart';
import 'package:flutter/material.dart';
import 'package:wear/wear.dart';
import 'package:wearable_rotary/wearable_rotary.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late StreamSubscription<RotaryEvent> rotarySubscription;
  int counter = 0;
  @override
  void initState() {
     rotarySubscription=
    rotaryEvents.listen((RotaryEvent event) {
      if (event.direction == RotaryDirection.clockwise) {
        jump();
        _increment();
      } else if (event.direction == RotaryDirection.counterClockwise) {
        jump();
        setState(() {
          counter--;
        });
      }
    });
    super.initState();
  }

  void _increment(){
    setState(() {
      counter++;
    });
  }

  @override
  void dispose() {
    rotarySubscription.cancel();
    super.dispose();
  }


  static double birdy = 0;
  double initialPos = birdy;
  double height = 0;
  double time = 0;
  double gravity = -4.9;
  double velocity = 3.5;
  double birdWidth = 0.1;
  double birdHeight = 0.1;

  bool gameHasStarted = false;

  static List<double> barrierX = [2, 2 + 1.5];
  static double barrierwidth = 0.5;
  List<List<double>> barrierheight = [
    [0.6, 0.4],
    [0.4, 0.6]
  ];

  void startGame() {
    gameHasStarted = true;
    Timer.periodic(Duration(milliseconds: 10), (timer) {
      height = gravity * time * time + velocity * time;
      setState(() {
        birdy = initialPos - height;
      });

      if (birdIsDead()) {
        timer.cancel();
        gameHasStarted = false;
        _showDialog();
      }
      moveMap();

      time += 0.01;
    });
  }

  void jump() {
    time = 0;
    initialPos = birdy;
  }

  void moveMap(){
    for(int i = 0;i<barrierX.length;i++){
      setState(() {
        barrierX[i] -= 0.005;
      });

      if(barrierX[i] < -1.5){
        barrierX[i] += 3;
      }
    }
  }

  bool birdIsDead() {
    if (birdy < -1 || birdy > 1) {
      return true;
    }
    for (int i = 0; i < barrierX.length; i++) {
      if (barrierX[i] <= birdWidth &&
          barrierX[i] + barrierwidth >= -birdWidth &&
          (birdy <= -1 + barrierheight[i][0] ||
              birdy + birdHeight >= 1 - barrierheight[i][1])) {
        return true;
      }
    }
    return false;
  }

  void resetGame() {
    Navigator.pop(context);
    setState(() {
      birdy = 0;
      gameHasStarted = false;
      time = 0;
      initialPos = birdy;
    });
  }

  void _showDialog() {
    final alertDialogWidth = MediaQuery.of(context).size.width * 0.25; // Adjust as needed
    final alertDialogHeight = MediaQuery.of(context).size.height * 0.25; // Adjust as needed
    final titleFontSize = alertDialogWidth ; // Adjust as needed
    final actionFontSize = alertDialogWidth ;
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            contentPadding: EdgeInsets.symmetric(
              vertical: MediaQuery.of(context).size.height * 0.25, // Adjust as needed
              horizontal: MediaQuery.of(context).size.width * 0.25, // Adjust as needed
            ),
            backgroundColor: Colors.brown,
            title: Center(
              child: Text(
                'G A M E  O V E R',
                style: TextStyle(color: Colors.white,fontSize: titleFontSize),
              ),
            ),
            actions: [
              GestureDetector(
                onTap: resetGame,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Container(
                    padding: EdgeInsets.all(7),
                    color: Colors.white,
                    child:  Center(
                      child: Text(
                        'PLAY AGAIN',
                        style: TextStyle(color: Colors.brown,fontSize: actionFontSize),
                      ),
                    ),
                  ),
                ),
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return WatchShape(builder: (BuildContext context, WearShape shape, Widget? child) {
      return GestureDetector(
        onTap: gameHasStarted ? jump : startGame,
        child: Scaffold(
          body: Column(
            children: [
              Expanded(
                  flex: 3,
                  child: Container(
                    color: Colors.blue,
                    child: Center(
                      child: Stack(
                        children: [
                          MyBird(
                            birdHeight: birdHeight,
                            birdWidth: birdWidth,
                            birdY: birdy,
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height/2,
                            alignment: const Alignment(0, -0.2),
                            child: Text(
                              gameHasStarted ? '' : 'T A P  T O  P L A Y',
                              style: const TextStyle(color: Colors.white, fontSize: 10,
                              ),
                            ),
                          ),
                          MyBarrier(
                            barrierX: barrierX[0],
                            barrierWidth: barrierwidth,
                            barrierHeight: barrierheight[0][0],
                            isThisBottomBarrier: false,
                          ),
                          MyBarrier(
                            barrierX: barrierX[0],
                            barrierWidth: barrierwidth,
                            barrierHeight: barrierheight[0][1],
                            isThisBottomBarrier: true,
                          ),
                          MyBarrier(
                            barrierX: barrierX[1],
                            barrierWidth: barrierwidth,
                            barrierHeight: barrierheight[1][0],
                            isThisBottomBarrier: false,
                          ),
                          MyBarrier(
                            barrierX: barrierX[1],
                            barrierWidth: barrierwidth,
                            barrierHeight: barrierheight[1][1],
                            isThisBottomBarrier: true,
                          ),
                        ],
                      ),
                    ),
                  )),
              Expanded(
                  child: Container(
                    color: Colors.brown,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('$counter'),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      );
    },
    );
  }
}
