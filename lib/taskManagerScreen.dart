import 'package:flutter/material.dart';
import 'package:untitled1/task_model.dart';





class TaskManagerScreen extends StatefulWidget {
  @override
  _TaskManagerScreenState createState() => _TaskManagerScreenState();
}

class _TaskManagerScreenState extends State<TaskManagerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<TaskModel> upcomingTasks = [];
  List<TaskModel> doneTasks = [];
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Add some sample tasks
    upcomingTasks.addAll([
      TaskModel(
        id: '1',
        title: 'Buy groceries',
        desc: 'Milk, bread, eggs',
      ),
      TaskModel(
          id: '2',
          title: 'Finish project',
          desc: 'Tryfdnfsdjfnsd'
      ),
    ]);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _addTask() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Task Title',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _titleController.clear();
                _descriptionController.clear();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_titleController.text.isNotEmpty) {
                  setState(() {
                    upcomingTasks.add(TaskModel(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      title: _titleController.text,
                      desc: _descriptionController.text,
                    ));
                  });
                  Navigator.of(context).pop();
                  _titleController.clear();
                  _descriptionController.clear();
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _markAsDone(TaskModel task) {
    setState(() {
      upcomingTasks.remove(task);
      doneTasks.insert(0, task);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Task marked as done!')),
    );
  }

  void _markAsUpcoming(TaskModel task) {
    setState(() {
      doneTasks.remove(task);
      upcomingTasks.insert(0, task);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Task moved to upcoming!')),
    );
  }

  Widget _buildTaskItem(TaskModel task, bool isUpcoming) {
    return Dismissible(
      key: Key(task.id),
      direction: isUpcoming ? DismissDirection.startToEnd : DismissDirection.endToStart,
      background: Container(
        alignment: isUpcoming ? Alignment.centerLeft : Alignment.centerRight,
        padding: EdgeInsets.symmetric(horizontal: 20),
        color: isUpcoming ? Colors.green : Colors.orange,
        child: Icon(
          isUpcoming ? Icons.check : Icons.undo,
          color: Colors.white,
          size: 28,
        ),
      ),
      onDismissed: (direction) {
        if (isUpcoming) {
          _markAsDone(task);
        } else {
          _markAsUpcoming(task);
        }
      },
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 2,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: isUpcoming ? Colors.blue : Colors.green,
            child: Icon(
              isUpcoming ? Icons.schedule : Icons.check,
              color: Colors.white,
            ),
          ),
          title: Text(
            task.title,
            style: TextStyle(
              decoration: isUpcoming ? null : TextDecoration.lineThrough,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: Icon(
            isUpcoming ? Icons.swipe_left : Icons.swipe_right,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }


  Widget _buildTaskList(List<TaskModel> tasks, bool isUpcoming) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isUpcoming ? Icons.schedule : Icons.check_circle_outline,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              isUpcoming ? 'No upcoming tasks' : 'No completed tasks',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            if (isUpcoming) SizedBox(height: 8),
            if (isUpcoming)
              Text(
                'Tap + to add a new task',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        return _buildTaskItem(tasks[index], isUpcoming);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task Manager'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: Icon(Icons.schedule),
              text: 'Upcoming (${upcomingTasks.length})',
            ),
            Tab(
              icon: Icon(Icons.done),
              text: 'Done (${doneTasks.length})',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTaskList(upcomingTasks, true),
          _buildTaskList(doneTasks, false),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        child: Icon(Icons.add),
        tooltip: 'Add new task',
      ),
    );
  }
}