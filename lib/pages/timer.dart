import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  Duration initialDuration = const Duration();
  Duration remaining = const Duration();
  Timer? countdownTimer;
  bool isRunning = false;

  int selectedHours = 0;
  int selectedMinutes = 0;
  int selectedSeconds = 0;

  void startTimer() {
    if (isRunning) return;

    // Set duration when Start is pressed
    setState(() {
      initialDuration = Duration(
        hours: selectedHours,
        minutes: selectedMinutes,
        seconds: selectedSeconds,
      );
      remaining = initialDuration;
      isRunning = true;
    });

    if (remaining.inSeconds == 0) return;

    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remaining.inSeconds <= 1) {
        timer.cancel();
        setState(() {
          isRunning = false;
          remaining = Duration.zero;
        });
      } else {
        setState(() {
          remaining -= const Duration(seconds: 1);
        });
      }
    });
  }

  void pauseTimer() {
    countdownTimer?.cancel();
    setState(() {
      isRunning = false;
    });
  }

  void resetTimer() {
    countdownTimer?.cancel();
    setState(() {
      isRunning = false;
      remaining = Duration.zero;
    });
  }

  String formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(duration.inHours)}:"
        "${twoDigits(duration.inMinutes.remainder(60))}:"
        "${twoDigits(duration.inSeconds.remainder(60))}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Timer')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Spacer(),
            Text(
              formatTime(remaining),
              style: const TextStyle(fontSize: 60, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            if (!isRunning && remaining == Duration.zero)
              Column(
                children: [
                  SizedBox(
                    height: 150,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        buildPicker('Hours', 0, 23, (val) {
                          setState(() {
                            selectedHours = val;
                          });
                        }),
                        buildPicker('Minutes', 0, 59, (val) {
                          setState(() {
                            selectedMinutes = val;
                          });
                        }),
                        buildPicker('Seconds', 0, 59, (val) {
                          setState(() {
                            selectedSeconds = val;
                          });
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: isRunning ? pauseTimer : startTimer,
                  child: Text(isRunning ? 'Pause' : 'Start'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: resetTimer,
                  child: const Text('Reset'),
                ),
              ],
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget buildPicker(String label, int min, int max, ValueChanged<int> onChanged) {
    return Column(
      children: [
        Text(label),
        SizedBox(
          width: 80,
          height: 100,
          child: CupertinoPicker(
            scrollController: FixedExtentScrollController(initialItem: 0),
            itemExtent: 32,
            onSelectedItemChanged: onChanged,
            children: List.generate(
              max - min + 1,
              (index) => Center(child: Text('${min + index}')),
            ),
          ),
        ),
      ],
    );
  }
}
