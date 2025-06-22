import 'dart:async';
import 'package:check_timer/settings.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

const kActiveColor = Color(0xff7DA44F);
const kInActiveColor = Color(0xff8A8886);
const kBarColor = Color(0xff302D2A);

void main() {
  // SystemChrome.setEnabledSystemUIOverlays([]);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(body: MyApp(), backgroundColor: kInActiveColor),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

bool hasStarted = false;
int oppUp = 0;
int oppDown = 0;

bool isUpActive = false;
bool isDownActive = false;
Timer? timerUp;
Timer? timerDown;
int maxTime = 10 * 60; //In minutes
int currentTimeUp = maxTime;
int currentTimeDown = maxTime;

bool hasEnded = false;
bool hasPaused = false;
int whoLost = -1; // -1 -> No one, 0 -> Up, 1 -> Down
int currentPlayer = -1; //0 -> Up, 1 -> Down

class _MyAppState extends State<MyApp> {
  void startTimerUp() {
    timerUp = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (currentTimeUp > 0 && isUpActive) {
        setState(() {
          currentTimeUp--;
        });
      } else if (currentTimeUp <= 0) {
        gameOver();
        setState(() {
          hasEnded = true;
          whoLost = 0;
        });
      }
    });
  }

  void startTimerDown() {
    timerDown = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (currentTimeDown > 0 && isDownActive) {
        setState(() {
          currentTimeDown--;
        });
      } else if (currentTimeDown <= 0) {
        gameOver();
        setState(() {
          hasEnded = true;
          whoLost = 1;
        });
      }
    });
  }

  void stopTimerUp() {
    timerUp?.cancel();
  }

  void stopTimerDown() {
    timerDown?.cancel();
  }

  void restartGame() {
    setState(() {
      stopTimerUp();
      stopTimerDown();
      currentTimeDown = currentTimeUp = maxTime;
      oppUp = oppDown = 0;
      hasStarted = hasEnded = false;
      isDownActive = isUpActive = false;
      whoLost = -1;
      hasPaused = false;
      currentPlayer = -1;
    });
  }

  void pauseGame() {
    if (hasEnded == false) {
      hasPaused = !hasPaused;
      if (hasPaused == true) {
        stopTimerDown();
        stopTimerUp();
        currentPlayer = isUpActive ? 0 : 1;
        setState(() {
          isDownActive = isUpActive = false;
        });
      } else {
        if (currentPlayer == 0) {
          //Top player is active
          startTimerUp();
          stopTimerDown();
          setState(() {
            isUpActive = true;
            isDownActive = false;
          });
        } else {
          //Down player is active
          startTimerDown();
          stopTimerUp();
          setState(() {
            isDownActive = true;
            isUpActive = false;
          });
        }
      }
    }
  }

  void gameOver() {
    stopTimerDown();
    stopTimerUp();
    hasPaused = false;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 5,
          child: TextButton(
            style: TextButton.styleFrom(
                backgroundColor: (whoLost == 0)
                    ? Colors.red
                    : isUpActive
                        ? kActiveColor
                        : kInActiveColor),
            onPressed: () => setState(() {
              if (hasEnded == true) {
                print("Game over bro");
                gameOver();
              } else if (isUpActive == true ||
                  hasStarted == false ||
                  hasPaused) {
                stopTimerUp();
                startTimerDown();
                if (hasStarted != false) {
                  oppUp++;
                }
                hasPaused = false;
                isDownActive = true;
                isUpActive = false;
                hasStarted = true;
              }
            }),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Transform.rotate(
                  angle: math.pi,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 70),
                    child: Text(
                      "${currentTimeUp ~/ 60}:${(currentTimeUp % 60).toString().padLeft(2, "0")}",
                      style: TextStyle(
                        fontSize: 120,
                        color: isUpActive ? Colors.white : Colors.black,
                        // fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Transform.rotate(
                      angle: math.pi,
                      child: Text(
                        "Moves : $oppUp",
                        style: const TextStyle(
                            fontSize: 20, color: Colors.black54),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            color: kBarColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  //Restart
                  onPressed: restartGame,
                  icon: const Icon(
                    Icons.replay_outlined,
                    size: 40,
                    color: Color(0xff83817F),
                  ),
                ),
                IconButton(
                  //Pause button
                  onPressed: pauseGame,
                  icon: Icon(
                    (hasPaused) ? Icons.play_arrow : Icons.pause,
                    size: 40,
                    color: const Color(0xff83817F),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => Settings())),
                  icon: const Icon(
                    Icons.settings,
                    size: 40,
                    color: Color(0xff83817F),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 5,
          child: TextButton(
            style: TextButton.styleFrom(
                backgroundColor: (whoLost == 1)
                    ? Colors.red
                    : isDownActive
                        ? kActiveColor
                        : kInActiveColor),
            onPressed: () => setState(() {
              if (hasEnded == true) {
                print("Game over bro");
                gameOver();
              } else if (isDownActive == true ||
                  hasStarted == false ||
                  hasPaused) {
                stopTimerDown();
                startTimerUp();
                if (hasStarted != false) {
                  oppDown++;
                }
                hasPaused = false;
                isUpActive = true;
                isDownActive = false;
                hasStarted = true;
              }
            }),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Moves : $oppDown",
                      style:
                          const TextStyle(fontSize: 20, color: Colors.black54),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 70),
                  child: Text(
                    "${currentTimeDown ~/ 60}:${(currentTimeDown % 60).toString().padLeft(2, "0")}",
                    style: TextStyle(
                        fontSize: 120,
                        color: isDownActive ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
