import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
  debugShowCheckedModeBanner: false,
  title: 'Tolist',
  theme: ThemeData(
    primarySwatch: Colors.deepPurple,
    textTheme: const TextTheme(
      bodyText2: TextStyle(fontFamily: 'Roboto'),
    ),
    colorScheme: ColorScheme.fromSwatch().copyWith( 
      secondary: Colors.deepPurpleAccent,
    ),
    scaffoldBackgroundColor: Colors.white, // Set scaffold background color to white
  ),
  home: const MyHomePage(title: 'To-Do List'),
);

  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class Task {
  String description;
  DateTime dateTime;
  TimeOfDay timeOfDay;

  Task(this.description)
      : dateTime = DateTime.now(),
        timeOfDay = TimeOfDay.now();

  String get date => DateFormat('yyyy-MM-dd').format(dateTime);
  String get day => DateFormat('EEEE').format(dateTime);
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Task> _tasks = [];
  final TextEditingController _taskController = TextEditingController();

  void _addTask() {
    setState(() {
      if (_taskController.text.isNotEmpty) {
        _tasks.add(Task(_taskController.text));
        _taskController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task added successfully!')),
        );
      }
    });
  }

  void _removeTask(int index) {
    setState(() {
      _tasks.removeAt(index);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task removed')),
      );
    });
  }

  void _editTaskDateTime(int index) async {
    DateTime? newDate = await showDatePicker(
      context: context,
      initialDate: _tasks[index].dateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (newDate != null) {
      TimeOfDay? newTime = await showTimePicker(
        context: context,
        initialTime: _tasks[index].timeOfDay,
      );

      if (newTime != null) {
        setState(() {
          _tasks[index].dateTime = newDate;
          _tasks[index].timeOfDay = newTime;
        });
      }
    }
  }

  void _editTaskDescription(int index) {
    final TextEditingController _editController = TextEditingController();
    _editController.text = _tasks[index].description;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Task Description'),
          content: TextField(
            controller: _editController,
            decoration: const InputDecoration(
              labelText: 'Task Description',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                setState(() {
                  if (_editController.text.isNotEmpty) {
                    _tasks[index].description = _editController.text;
                  }
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            TextField(
              controller: _taskController,
              decoration: const InputDecoration(
                labelText: 'Enter a new task',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _tasks.length,
                itemBuilder: (context, index) {
                  final task = _tasks[index];
                  final isPastDue = DateTime(
                    task.dateTime.year,
                    task.dateTime.month,
                    task.dateTime.day,
                    task.timeOfDay.hour,
                    task.timeOfDay.minute,
                  ).isBefore(DateTime.now());

                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    color: isPastDue ? Colors.red.shade400 : Colors.green.shade400, // Adjusted color based on condition
                    child: ListTile(
                      title: Text(
                        task.description,
                        style: TextStyle(
                          decoration: isPastDue
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          color: isPastDue ? Colors.grey : Colors.black,
                        ),
                      ),
                      subtitle: Text(
                          '${task.day}, ${task.date}, ${task.timeOfDay.format(context)}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _editTaskDescription(index),
                          ),
                          IconButton(
                            icon: const Icon(Icons.access_time),
                            onPressed: () => _editTaskDateTime(index),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _removeTask(index),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        child: const Icon(Icons.add),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
    );
  }
}
