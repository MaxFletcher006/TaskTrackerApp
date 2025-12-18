// debug-db.dart
import 'package:tasktracker/database/database.dart';
import 'package:tasktracker/models/task.dart';
import 'package:tasktracker/models/user.dart';

class DebugDB {
  final AppDatabase db = AppDatabase.instance;

  Future<void> run() async {
    print("=== DEBUG DATABASE START ===");

    // ----------- DELETE ----------

    // await db.deleteTask(0) ;
    // await db.deleteUser(4) ;

    // List<User> users = await db.getAllUsers() ;
    //  print("All tasks count = ${users.length}");
    // for (var u in users) {
    //   print(u.toString());
    // }

    // List<Task> allTasks = await db.getAllTasks();
    // print("All tasks count = ${allTasks.length}");
    // for (var t in allTasks) {
    //   print(t.toString());
    // }

    // // -------- USER TEST --------
    // User testUser = User(
    //   username: 'max',
    //   password: '1234',
    //   email: 'max@example.com',
    //   number: '99009900',
    // );

    // print("Creating user → ${testUser.toString()}");

    // int userId = await db.createNewUser(testUser);
    // print("User created: ID = $userId");

    // bool isValid = await db.isUserValid('max', '1234');
    // print("Login valid? $isValid");

    // bool reset = await db.resetPassword(
    //   'max',
    //   'newpass123',
    //   'max@example.com',
    //   '99009900',
    // );
    // print("Password reset = $reset");


    // -------- TASK TEST --------
    // Task newTask = Task(
    //   id: 0,
    //   user_id: userId,
    //   title: 'Sample Task',
    //   context: 'Debug test',
    //   deadline: '2025-12-01',
    //   isDone: false,
    // );

    // print("Creating task → ${newTask.toString()}");

    // int taskId = await db.createTask(newTask);
    // print("Task created: ID = $taskId");

    // bool updated = await db.updateTask(
    //   newTask.copyWith(id: taskId),
    //   1,
    // );
    // print("Task update → ${newTask.copyWith(id: taskId, isDone: true)}");
    // print("Task status update = $updated");


    // -------- EDIT TASK --------
    // Task editedTask = newTask.copyWith(
    //   id: taskId,
    //   title: "Edited Title",
    //   context: "Updated",
    //   isDone: true,
    // );

    // print("Editing task → ${editedTask.toString()}");

    // int rows = await db.editTask(editedTask, taskId);
    // print("Task edited rows = $rows");

    // List<Task> userTasks = await db.getTasksByUser(userId);
    // print("User($userId) tasks = ${userTasks.length}");
    // for (var t in userTasks) {
    //   print(t.toString());
    // }


    print("=== DEBUG DATABASE END ===");
  }
}
