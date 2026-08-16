import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const StudyFocusApp());
}

// ============================================================
// APP
// ============================================================

class StudyFocusApp extends StatefulWidget {
  const StudyFocusApp({super.key});

  @override
  State<StudyFocusApp> createState() => _StudyFocusAppState();
}

class _StudyFocusAppState extends State<StudyFocusApp> {
  ThemeMode themeMode = ThemeMode.light;
  bool timerSound = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'StudyFocus',
      themeMode: themeMode,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: HomeScreen(
        isDark: themeMode == ThemeMode.dark,
        timerSound: timerSound,
        onThemeChanged: (dark) {
          setState(() {
            themeMode =
                dark ? ThemeMode.dark : ThemeMode.light;
          });
        },
        onSoundChanged: (value) {
          setState(() {
            timerSound = value;
          });
        },
      ),
    );
  }
}

// ============================================================
// THEME
// ============================================================

class AppTheme {
  static final ThemeData light = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor:
        const Color(0xFFFFF8F8),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF9B5066),
      brightness: Brightness.light,
    ),
    cardTheme: const CardThemeData(
      elevation: 1,
      margin: EdgeInsets.zero,
      color: Color(0xFFFFF0F2),
    ),
    fontFamily: 'Arial',
  );

  static final ThemeData dark = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor:
        const Color(0xFF170E11),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFEA1766),
      brightness: Brightness.dark,
    ),
    cardTheme: const CardThemeData(
      elevation: 1,
      margin: EdgeInsets.zero,
      color: Color(0xFF24171B),
    ),
    fontFamily: 'Arial',
  );
}

// ============================================================
// TASK MODEL
// ============================================================

class StudyTask {
  String title;
  bool completed;

  StudyTask({
    required this.title,
    this.completed = false,
  });
}

// ============================================================
// HOME SCREEN
// ============================================================

class HomeScreen extends StatefulWidget {
  final bool isDark;
  final bool timerSound;
  final Function(bool) onThemeChanged;
  final Function(bool) onSoundChanged;

  const HomeScreen({
    super.key,
    required this.isDark,
    required this.timerSound,
    required this.onThemeChanged,
    required this.onSoundChanged,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;

  // ----------------------------------------------------------
  // MOTIVATION
  // A random short motivation is selected when the app opens.
  // ----------------------------------------------------------

  final List<String> motivations = [
    'Start now. Your future self is watching. 🔥',
    'One focused hour can change your day. 📚',
    'Discipline beats motivation. 💪',
    'Stop waiting. Start studying. ⚡',
    'Small progress is still progress. 🌱',
    'Your goal needs your effort today. 🎯',
    'Study now. Relax later. 📖',
    'Consistency will take you further. 🚀',
    'Do the work even when you do not feel like it. 🔥',
    'One session at a time. You can do this. 💯',
    'Your exam will not prepare itself. 📚',
    'Make today count. ⭐',
    'Focus on the next 25 minutes. ⏱️',
    'Less scrolling. More studying. 📵',
    'You do not need motivation. You need action. 💪',
  ];

  late String motivation;

  // ----------------------------------------------------------
  // TASKS
  // ----------------------------------------------------------

  List<StudyTask> tasks = [
    StudyTask(title: 'Revise Accounts Chapter 2'),
    StudyTask(title: 'Law Revision'),
    StudyTask(title: 'Solve 20 Maths Questions'),
  ];

  // ----------------------------------------------------------
  // STUDY DATA
  // ----------------------------------------------------------

  int dailyGoalMinutes = 180;
  int todayStudyMinutes = 100;

  final List<int> weeklyMinutes = [
    135,
    100,
    185,
    260,
    150,
    70,
    100,
  ];

  int monthlyMinutes = 1000;
  int monthlyGoalMinutes = 6000;

  int xp = 320;
  int streak = 7;

  @override
  void initState() {
    super.initState();

    final random = Random();
    motivation =
        motivations[random.nextInt(motivations.length)];
  }

  int get completedTasks {
    return tasks
        .where((task) => task.completed)
        .length;
  }

  // ----------------------------------------------------------
  // TASK FUNCTIONS
  // ----------------------------------------------------------

  void addTask(String title) {
    if (title.trim().isEmpty) {
      return;
    }

    setState(() {
      tasks.add(
        StudyTask(
          title: title.trim(),
        ),
      );
    });
  }

  void toggleTask(int index) {
    setState(() {
      tasks[index].completed =
          !tasks[index].completed;

      if (tasks[index].completed) {
        xp += 10;
      } else {
        xp -= 10;
      }

      if (xp < 0) {
        xp = 0;
      }
    });
  }

  void deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });
  }

  // ----------------------------------------------------------
  // STUDY TIME
  // ----------------------------------------------------------

  void addStudyMinutes(int minutes) {
    setState(() {
      todayStudyMinutes += minutes;
      monthlyMinutes += minutes;
      xp += minutes ~/ 5;
    });
  }

  // ----------------------------------------------------------
  // MINUTES → HOURS
  // ----------------------------------------------------------

  String formatMinutes(int minutes) {
    final int hours = minutes ~/ 60;
    final int remainingMinutes = minutes % 60;

    if (hours == 0) {
      return '${remainingMinutes}m';
    }

    if (remainingMinutes == 0) {
      return '${hours}h';
    }

    return '${hours}h ${remainingMinutes}m';
  }

  // ----------------------------------------------------------
  // BUILD
  // ----------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      TasksPage(
        tasks: tasks,
        completedTasks: completedTasks,
        dailyGoalMinutes: dailyGoalMinutes,
        todayStudyMinutes: todayStudyMinutes,
        streak: streak,
        xp: xp,
        motivation: motivation,
        onToggleTask: toggleTask,
        onDeleteTask: deleteTask,
        onAddTask: addTask,
        onChangeGoal: (value) {
          setState(() {
            dailyGoalMinutes = value;
          });
        },
        onRewards: () {
          showRewards(context);
        },
      ),

      FocusPage(
        timerSound: widget.timerSound,
        onSessionComplete: addStudyMinutes,
      ),

      ProgressPage(
        weeklyMinutes: weeklyMinutes,
        monthlyMinutes: monthlyMinutes,
        monthlyGoalMinutes: monthlyGoalMinutes,
        formatMinutes: formatMinutes,
      ),

      SettingsPage(
        isDark: widget.isDark,
        timerSound: widget.timerSound,
        onThemeChanged: widget.onThemeChanged,
        onSoundChanged: widget.onSoundChanged,
        dailyGoalMinutes: dailyGoalMinutes,
        onDailyGoalChanged: (value) {
          setState(() {
            dailyGoalMinutes = value;
          });
        },
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: pages[selectedIndex],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(
              Icons.checklist_rounded,
            ),
            label: 'Tasks',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.timer_outlined,
            ),
            label: 'Focus',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.insights_rounded,
            ),
            label: 'Progress',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.settings_outlined,
            ),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // REWARDS
  // ----------------------------------------------------------

  void showRewards(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  '🎁 Rewards',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 18),

                Text(
                  '⭐ $xp XP',
                  style: const TextStyle(
                    fontSize: 20,
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  'Unlocked stickers',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                const Wrap(
                  spacing: 14,
                  runSpacing: 14,
                  children: [
                    RewardSticker(
                      emoji: '🌱',
                      name: 'Starter',
                    ),
                    RewardSticker(
                      emoji: '📚',
                      name: 'Reader',
                    ),
                    RewardSticker(
                      emoji: '🔥',
                      name: 'Focused',
                    ),
                    RewardSticker(
                      emoji: '⭐',
                      name: 'Star',
                    ),
                  ],
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ============================================================
// REWARD STICKER
// ============================================================

class RewardSticker extends StatelessWidget {
  final String emoji;
  final String name;

  const RewardSticker({
    super.key,
    required this.emoji,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
            Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(
            emoji,
            style: const TextStyle(
              fontSize: 34,
            ),
          ),
          const SizedBox(height: 4),
          Text(name),
        ],
      ),
    );
  }
}

// ============================================================
// TASKS PAGE
// ============================================================

class TasksPage extends StatelessWidget {
  final List<StudyTask> tasks;
  final int completedTasks;
  final int dailyGoalMinutes;
  final int todayStudyMinutes;
  final int streak;
  final int xp;
  final String motivation;

  final Function(int) onToggleTask;
  final Function(int) onDeleteTask;
  final Function(String) onAddTask;
  final Function(int) onChangeGoal;
  final VoidCallback onRewards;

  const TasksPage({
    super.key,
    required this.tasks,
    required this.completedTasks,
    required this.dailyGoalMinutes,
    required this.todayStudyMinutes,
    required this.streak,
    required this.xp,
    required this.motivation,
    required this.onToggleTask,
    required this.onDeleteTask,
    required this.onAddTask,
    required this.onChangeGoal,
    required this.onRewards,
  });

  String formatMinutes(int minutes) {
    final int hours = minutes ~/ 60;
    final int remainingMinutes = minutes % 60;

    if (hours == 0) {
      return '${remainingMinutes}m';
    }

    if (remainingMinutes == 0) {
      return '${hours}h';
    }

    return '${hours}h ${remainingMinutes}m';
  }

  @override
  Widget build(BuildContext context) {
    final double goalProgress =
        dailyGoalMinutes == 0
            ? 0
            : (todayStudyMinutes /
                    dailyGoalMinutes)
                .clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Today 🌸',
          style: TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          IconButton(
            onPressed: onRewards,
            icon: const Icon(
              Icons.auto_awesome,
            ),
            tooltip: 'Rewards',
          ),
        ],
      ),

      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: () {
          showAddTaskDialog(context);
        },
        icon: const Icon(Icons.add),
        label: const Text('Task'),
      ),

      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          18,
          10,
          18,
          100,
        ),
        children: [
          // --------------------------------------------------
          // AUTOMATIC MOTIVATION
          // --------------------------------------------------

          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Text(
                    '✨',
                    style: TextStyle(
                      fontSize: 30,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      motivation,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // --------------------------------------------------
          // DAILY GOAL
          // --------------------------------------------------

          _buildGoalCard(
            context,
            goalProgress,
          ),

          const SizedBox(height: 24),

          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Today's To-Do",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$completedTasks/${tasks.length}',
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          if (tasks.isEmpty)
            _emptyTasks(context),

          ...List.generate(
            tasks.length,
            (index) {
              final StudyTask task = tasks[index];

              return Padding(
                padding:
                    const EdgeInsets.only(bottom: 12),
                child: Dismissible(
                  key: ValueKey(
                    '${task.title}-$index',
                  ),
                  direction:
                      DismissDirection.endToStart,
                  onDismissed: (_) {
                    onDeleteTask(index);
                  },
                  background: Container(
                    alignment:
                        Alignment.centerRight,
                    padding:
                        const EdgeInsets.only(
                      right: 20,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.shade400,
                      borderRadius:
                          BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  child: Card(
                    child: ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      leading: Checkbox(
                        value: task.completed,
                        onChanged: (_) {
                          onToggleTask(index);
                        },
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(5),
                        ),
                      ),
                      title: Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 17,
                          decoration:
                              task.completed
                                  ? TextDecoration
                                      .lineThrough
                                  : TextDecoration
                                      .none,
                        ),
                      ),
                      trailing: IconButton(
                        onPressed: () {
                          onDeleteTask(index);
                        },
                        icon: const Icon(
                          Icons.close,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // GOAL CARD
  // ----------------------------------------------------------

  Widget _buildGoalCard(
    BuildContext context,
    double progress,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              'Keep going! 🌷',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              "Today's study goal",
              style: TextStyle(
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 10),

            LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              borderRadius:
                  BorderRadius.circular(20),
            ),

            const SizedBox(height: 10),

            Text(
              '${formatMinutes(todayStudyMinutes)} / '
              '${formatMinutes(dailyGoalMinutes)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Text(
                  '🔥 $streak day streak',
                ),
                const SizedBox(width: 18),
                Text(
                  '⭐ $xp XP',
                ),
              ],
            ),

            const SizedBox(height: 14),

            OutlinedButton.icon(
              onPressed: () {
                showGoalDialog(context);
              },
              icon: const Icon(
                Icons.edit_outlined,
              ),
              label: const Text(
                'Set daily goal',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // EMPTY TASKS
  // ----------------------------------------------------------

  Widget _emptyTasks(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            const Text(
              '📝',
              style: TextStyle(
                fontSize: 45,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Nothing planned yet.',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Add what you need to accomplish today.',
              style: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.65),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // ADD TASK DIALOG
  // ----------------------------------------------------------

  void showAddTaskDialog(
    BuildContext context,
  ) {
    final TextEditingController controller =
        TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add task'),

          content: TextField(
            controller: controller,
            autofocus: true,
            decoration:
                const InputDecoration(
              hintText:
                  'What do you need to do today?',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) {
              onAddTask(controller.text);
              Navigator.pop(dialogContext);
            },
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),

            FilledButton(
              onPressed: () {
                onAddTask(controller.text);
                Navigator.pop(dialogContext);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  // ----------------------------------------------------------
  // DAILY GOAL DIALOG
  // ----------------------------------------------------------

  void showGoalDialog(
    BuildContext context,
  ) {
    int selected = dailyGoalMinutes;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
            context,
            setDialogState,
          ) {
            return AlertDialog(
              title: const Text(
                '🎯 Daily study goal',
              ),

              content: Column(
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  Text(
                    '${selected ~/ 60}h '
                    '${selected % 60}m',
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  Slider(
                    min: 30,
                    max: 720,
                    divisions: 23,
                    value:
                        selected.toDouble(),
                    label:
                        '${selected ~/ 60}h '
                        '${selected % 60}m',
                    onChanged: (value) {
                      setDialogState(() {
                        selected =
                            value.round();
                      });
                    },
                  ),
                ],
              ),

              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(
                      dialogContext,
                    );
                  },
                  child: const Text(
                    'Cancel',
                  ),
                ),

                FilledButton(
                  onPressed: () {
                    onChangeGoal(selected);
                    Navigator.pop(
                      dialogContext,
                    );
                  },
                  child: const Text(
                    'Save',
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// ============================================================
// FOCUS PAGE
// ============================================================

class FocusPage extends StatefulWidget {
  final bool timerSound;
  final Function(int) onSessionComplete;

  const FocusPage({
    super.key,
    required this.timerSound,
    required this.onSessionComplete,
  });

  @override
  State<FocusPage> createState() =>
      _FocusPageState();
}

class _FocusPageState extends State<FocusPage> {
  Timer? timer;

  int selectedStudyMinutes = 25;
  int selectedBreakMinutes = 5;

  int remainingSeconds = 25 * 60;

  bool running = false;
  bool isBreak = false;

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  // ----------------------------------------------------------
  // START
  // ----------------------------------------------------------

  void startTimer() {
    if (running) {
      return;
    }

    setState(() {
      running = true;
    });

    timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (!mounted) {
          timer?.cancel();
          return;
        }

        if (remainingSeconds <= 0) {
          timer?.cancel();

          if (!isBreak) {
            widget.onSessionComplete(
              selectedStudyMinutes,
            );

            setState(() {
              isBreak = true;
              remainingSeconds =
                  selectedBreakMinutes * 60;
              running = false;
            });

            showMessage(
              '🎉 Study session complete!',
            );
          } else {
            setState(() {
              isBreak = false;
              remainingSeconds =
                  selectedStudyMinutes * 60;
              running = false;
            });

            showMessage(
              'Break finished. Ready to focus? 📚',
            );
          }

          return;
        }

        setState(() {
          remainingSeconds--;
        });
      },
    );
  }

  // ----------------------------------------------------------
  // PAUSE
  // ----------------------------------------------------------

  void pauseTimer() {
    timer?.cancel();

    setState(() {
      running = false;
    });
  }

  // ----------------------------------------------------------
  // RESET
  // ----------------------------------------------------------

  void resetTimer() {
    timer?.cancel();

    setState(() {
      running = false;
      isBreak = false;
      remainingSeconds =
          selectedStudyMinutes * 60;
    });
  }

  // ----------------------------------------------------------
  // SELECT STUDY TIME
  // ----------------------------------------------------------

  void selectStudyTime(int minutes) {
    if (running) {
      return;
    }

    setState(() {
      selectedStudyMinutes = minutes;
      remainingSeconds = minutes * 60;
      isBreak = false;
    });
  }

  // ----------------------------------------------------------
  // SELECT BREAK TIME
  // ONLY 5 AND 10 MINUTES
  // ----------------------------------------------------------

  void selectBreakTime(int minutes) {
    if (running) {
      return;
    }

    setState(() {
      selectedBreakMinutes = minutes;
    });
  }

  // ----------------------------------------------------------
  // MESSAGE
  // ----------------------------------------------------------

  void showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior:
              SnackBarBehavior.floating,
        ),
      );
  }

  // ----------------------------------------------------------
  // TIMER TEXT
  // ----------------------------------------------------------

  String get timerText {
    final int hours =
        remainingSeconds ~/ 3600;

    final int minutes =
        (remainingSeconds % 3600) ~/ 60;

    final int seconds =
        remainingSeconds % 60;

    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  // ----------------------------------------------------------
  // BUILD
  // ----------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Focus ⏱️',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                children: [
                  Text(
                    isBreak
                        ? 'Break ☕'
                        : 'Focus Session 📚',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 30),

                  FittedBox(
                    child: Text(
                      timerText,
                      style: const TextStyle(
                        fontSize: 58,
                        fontWeight:
                            FontWeight.w300,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  FilledButton.icon(
                    onPressed: running
                        ? pauseTimer
                        : startTimer,
                    icon: Icon(
                      running
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                    ),
                    label: Text(
                      running
                          ? 'Pause'
                          : 'Start',
                    ),
                  ),

                  const SizedBox(height: 10),

                  OutlinedButton(
                    onPressed: resetTimer,
                    child:
                        const Text('Reset'),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 22),

          const Text(
            'Study time',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _timeButton(
                25,
                selectedStudyMinutes == 25,
              ),
              _timeButton(
                45,
                selectedStudyMinutes == 45,
              ),
              _timeButton(
                60,
                selectedStudyMinutes == 60,
              ),
              _timeButton(
                90,
                selectedStudyMinutes == 90,
              ),
            ],
          ),

          const SizedBox(height: 24),

          const Text(
            'Break',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          Wrap(
            spacing: 10,
            children: [
              _breakButton(5),
              _breakButton(10),
            ],
          ),

          const SizedBox(height: 24),

          Card(
            child: ListTile(
              leading: const Text(
                '💧',
                style: TextStyle(
                  fontSize: 28,
                ),
              ),
              title: const Text(
                'Remember to hydrate',
                style: TextStyle(
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
              subtitle: const Text(
                'Drink some water during your break.',
              ),
            ),
          ),

          const SizedBox(height: 15),

          Card(
            child: ListTile(
              leading: const Text(
                '💪',
                style: TextStyle(
                  fontSize: 28,
                ),
              ),
              title: const Text(
                'Keep going',
                style: TextStyle(
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
              subtitle: const Text(
                'Small sessions become big results.',
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // STUDY BUTTON
  // ----------------------------------------------------------

  Widget _timeButton(
    int minutes,
    bool selected,
  ) {
    return ChoiceChip(
      label: Text('$minutes min'),
      selected: selected,
      onSelected: (_) {
        selectStudyTime(minutes);
      },
    );
  }

  // ----------------------------------------------------------
  // BREAK BUTTON
  // ----------------------------------------------------------

  Widget _breakButton(
    int minutes,
  ) {
    return ChoiceChip(
      label: Text('$minutes min'),
      selected:
          selectedBreakMinutes == minutes,
      onSelected: (_) {
        selectBreakTime(minutes);
      },
    );
  }
}

// ============================================================
// PROGRESS PAGE
// ============================================================

class ProgressPage extends StatelessWidget {
  final List<int> weeklyMinutes;
  final int monthlyMinutes;
  final int monthlyGoalMinutes;
  final String Function(int) formatMinutes;

  const ProgressPage({
    super.key,
    required this.weeklyMinutes,
    required this.monthlyMinutes,
    required this.monthlyGoalMinutes,
    required this.formatMinutes,
  });

  @override
  Widget build(BuildContext context) {
    final double monthlyProgress =
        monthlyGoalMinutes == 0
            ? 0
            : (monthlyMinutes /
                    monthlyGoalMinutes)
                .clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Progress 📊',
          style: TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          18,
          10,
          18,
          30,
        ),
        children: [
          // --------------------------------------------------
          // DAILY PROGRESS BAR
          // --------------------------------------------------

          _dailyProgressChart(context),

          const SizedBox(height: 20),

          // --------------------------------------------------
          // MONTHLY PROGRESS
          // --------------------------------------------------

          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Monthly Progress 📅',
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // IMPORTANT:
                  // Minutes are converted to hours here.
                  //
                  // Example:
                  // 1000 minutes = 16h 40m
                  //
                  // The progress BAR is NOT changed.

                  Text(
                    '${formatMinutes(monthlyMinutes)} '
                    'studied this month',
                    style: const TextStyle(
                      fontSize: 17,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // SAME BAR PROGRESS
                  LinearProgressIndicator(
                    value: monthlyProgress,
                    minHeight: 12,
                    borderRadius:
                        BorderRadius.circular(
                      20,
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'Monthly goal: 100 hours',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // DAILY PROGRESS
  // ONLY THE DAILY BAR CHART IS SHOWN.
  // NO STUDY HISTORY SECTION.
  // ==========================================================

  Widget _dailyProgressChart(
    BuildContext context,
  ) {
    const List<String> days = [
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ];

    int maxValue = 0;

    for (final int value in weeklyMinutes) {
      if (value > maxValue) {
        maxValue = value;
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          20,
          24,
          20,
          22,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              'Daily Progress 📊',
              style: TextStyle(
                fontSize: 23,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              height: 240,
              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.end,
                mainAxisAlignment:
                    MainAxisAlignment
                        .spaceAround,
                children: List.generate(
                  7,
                  (index) {
                    final int value =
                        weeklyMinutes[index];

                    final double height =
                        maxValue == 0
                            ? 0
                            : (value /
                                    maxValue) *
                                160;

                    return Column(
                      mainAxisAlignment:
                          MainAxisAlignment.end,
                      children: [
                        Text(
                          formatMinutes(value),
                          style:
                              const TextStyle(
                            fontSize: 12,
                            fontWeight:
                                FontWeight
                                    .w600,
                          ),
                        ),

                        const SizedBox(
                          height: 6,
                        ),

                        Container(
                          width: 38,
                          height: height,
                          decoration:
                              BoxDecoration(
                            color: Theme.of(
                              context,
                            )
                                .colorScheme
                                .primary,
                            borderRadius:
                                const BorderRadius
                                    .vertical(
                              top: Radius
                                  .circular(
                                12,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: 8,
                        ),

                        Text(days[index]),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// SETTINGS PAGE
// ============================================================

class SettingsPage extends StatelessWidget {
  final bool isDark;
  final bool timerSound;
  final Function(bool) onThemeChanged;
  final Function(bool) onSoundChanged;

  final int dailyGoalMinutes;
  final Function(int) onDailyGoalChanged;

  const SettingsPage({
    super.key,
    required this.isDark,
    required this.timerSound,
    required this.onThemeChanged,
    required this.onSoundChanged,
    required this.dailyGoalMinutes,
    required this.onDailyGoalChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Settings ⚙️',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Text(
            'Appearance',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Card(
            child: SwitchListTile(
              title: const Text(
                'Dark mode',
              ),
              subtitle: const Text(
                'Use a darker theme at night.',
              ),
              value: isDark,
              onChanged: onThemeChanged,
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'Focus',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Card(
            child: SwitchListTile(
              title: const Text(
                'Timer sounds',
              ),
              subtitle: const Text(
                'Play a sound when the timer finishes.',
              ),
              value: timerSound,
              onChanged: onSoundChanged,
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'Study Goal',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Card(
            child: ListTile(
              leading: const Icon(
                Icons.flag_outlined,
              ),
              title: const Text(
                'Daily study goal',
              ),
              subtitle: Text(
                '${dailyGoalMinutes ~/ 60}h '
                '${dailyGoalMinutes % 60}m',
              ),
              trailing: const Icon(
                Icons.chevron_right,
              ),
              onTap: () {
                showDailyGoalDialog(
                  context,
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'Notifications',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          const Card(
            child: ListTile(
              leading: Icon(
                Icons.notifications_outlined,
              ),
              title: Text(
                'Task reminders',
              ),
              subtitle: Text(
                'Reminder notifications will be added '
                'in the full mobile version.',
              ),
            ),
          ),

          const SizedBox(height: 20),

          Card(
            child: Column(
              children: [
                const ListTile(
                  leading: Text(
                    '🎓',
                    style: TextStyle(
                      fontSize: 28,
                    ),
                  ),
                  title: Text(
                    'StudyFocus',
                    style: TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'Study • Focus • Progress',
                  ),
                ),

                ListTile(
                  leading: const Icon(
                    Icons.info_outline,
                  ),
                  title: const Text(
                    'About',
                  ),
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName:
                          'StudyFocus',
                      applicationVersion:
                          '1.0.0',
                      applicationLegalese:
                          'Made for focused students.',
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // DAILY GOAL DIALOG
  // ==========================================================

  void showDailyGoalDialog(
    BuildContext context,
  ) {
    int selected = dailyGoalMinutes;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
            context,
            setDialogState,
          ) {
            return AlertDialog(
              title: const Text(
                'Set daily goal',
              ),

              content: Column(
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  Text(
                    '${selected ~/ 60}h '
                    '${selected % 60}m',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  Slider(
                    min: 30,
                    max: 720,
                    divisions: 23,
                    value:
                        selected.toDouble(),
                    onChanged: (value) {
                      setDialogState(() {
                        selected =
                            value.round();
                      });
                    },
                  ),
                ],
              ),

              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(
                      dialogContext,
                    );
                  },
                  child: const Text(
                    'Cancel',
                  ),
                ),

                FilledButton(
                  onPressed: () {
                    onDailyGoalChanged(
                      selected,
                    );

                    Navigator.pop(
                      dialogContext,
                    );
                  },
                  child: const Text(
                    'Save',
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
