class Task {
  final int? id;
  final int user_id;
  final String title;
  final String context;
  final String? deadline; 
  final int isDone;

  const Task({
    this.id,
    required this.user_id,
    required this.title,
    required this.context,
    this.deadline,
    required this.isDone,
  });

  Task copyWith({
    int? id, 
    int? user_id,
    String? title, 
    String? context, 
    String? deadline,
    int? isDone,
  }) {
    return Task(
      id: id ?? this.id,
      user_id: user_id ?? this.user_id,
      title: title ?? this.title,
      context: context ?? this.context,
      deadline: deadline ?? this.deadline,
      isDone: isDone ?? this.isDone,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'user_id': user_id,
      'title': title,
      'context': context,
      'deadline': deadline,
      'isDone': isDone, 
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as int?,
      user_id: map['user_id'] as int,
      title: map['title'] as String,
      context: map['context'] as String,
      deadline: map['deadline'] as String?,
      isDone: map['isDone'] as int,
    );
  }

  @override
  String toString() {
    return 'Task(id: $id, user_id: $user_id, title: $title, '
           'deadline: $deadline, done: $isDone)';
  }
}