import 'package:flutter/material.dart';

import '../models/user.dart';
import '../models/task.dart';
import '../database/database.dart';

class TasksPage extends StatefulWidget {
  final User user;

  const TasksPage({super.key, required this.user});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> with SingleTickerProviderStateMixin {
  final AppDatabase db = AppDatabase.instance;
  late TabController _tabController;
  List<Task> inProgressTasks = [];
  List<Task> completedTasks = [];
  List<Task> postponedTasks = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadTasks();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTasks() async {
    final tasks = await db.getTasksByUser(widget.user.id!);
    final now = DateTime.now();

    setState(() {
      completedTasks = tasks.where((t) => t.isDone == 1).toList();
      
      inProgressTasks = tasks.where((t) {
        if (t.isDone == 1) return false;
        if (t.deadline == null || t.deadline!.isEmpty) return true;
        return DateTime.parse(t.deadline!).isAfter(now);
      }).toList();

      postponedTasks = tasks.where((t) {
        if (t.isDone == 1) return false;
        if (t.deadline == null || t.deadline!.isEmpty) return false;
        return DateTime.parse(t.deadline!).isBefore(now);
      }).toList();
    });
  }

  Future<void> _toggleTaskStatus(Task task) async {
    try {
      final newStatus = task.isDone == 1 ? 0 : 1;
      await db.updateTask(task, newStatus);
      _loadTasks();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(newStatus == 1 ? 'Task completed!' : 'Task uncompleted'),
          duration: const Duration(seconds: 1),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _deleteTask(Task task) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      try {
        await db.deleteTask(task.id!);
        _loadTasks();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task deleted')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _showAddTaskDialog() {
    final titleController = TextEditingController();
    final contextController = TextEditingController();
    final deadlineController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Task'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contextController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: deadlineController,
                decoration: const InputDecoration(
                  labelText: 'Deadline (YYYY-MM-DD)',
                  border: OutlineInputBorder(),
                  hintText: '2025-12-31 or leave empty',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isEmpty || contextController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Title and description are required')),
                );
                return;
              }

              final deadline = deadlineController.text.trim().isEmpty
                  ? null
                  : deadlineController.text.trim();

              final newTask = Task(
                user_id: widget.user.id!,
                title: titleController.text,
                context: contextController.text,
                deadline: deadline,
                isDone: 0,
              );

              try {
                await db.createTask(newTask);
                _loadTasks();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Task added!')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(Task task, {bool isPostponed = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isPostponed
            ? Border.all(color: Colors.red.shade300, width: 1)
            : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Checkbox(
          value: task.isDone == 1,
          onChanged: (value) => _toggleTaskStatus(task),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            decoration: task.isDone == 1 ? TextDecoration.lineThrough : null,
            color: task.isDone == 1 ? Colors.grey : Colors.black,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              task.context,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                decoration: task.isDone == 1 ? TextDecoration.lineThrough : null,
              ),
            ),
            if (task.deadline != null && task.deadline!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: isPostponed ? Colors.red : Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    task.deadline!,
                    style: TextStyle(
                      fontSize: 12,
                      color: isPostponed ? Colors.red : Colors.grey[600],
                      fontWeight: isPostponed ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () => _deleteTask(task),
        ),
      ),
    );
  }

  Widget _buildTaskList(List<Task> tasks, {bool isPostponed = false}) {
    if (tasks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No tasks',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        return _buildTaskCard(tasks[index], isPostponed: isPostponed);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'My Tasks',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue,
          tabs: [
            Tab(text: 'In Progress (${inProgressTasks.length})'),
            Tab(text: 'Completed (${completedTasks.length})'),
            Tab(text: 'Postponed (${postponedTasks.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTaskList(inProgressTasks),
          _buildTaskList(completedTasks),
          _buildTaskList(postponedTasks, isPostponed: true),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }
}