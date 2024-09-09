// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Todo {
  final String id;
  final String title;
  final bool isCompleted;

  const Todo({
    required this.id,
    required this.title,
    required this.isCompleted,
  });

  String toJson() => json.encode(toMap());

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      title: json['title'],
      isCompleted: json['isCompleted'] == 1 ? true : false,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'isCompleted': isCompleted ? 1 : 0,
    };
  }

  @override
  String toString() {
    return 'Todo(id: $id, title: $title, isCompleted: $isCompleted)';
  }

  Todo copyWith({
    String? id,
    String? title,
    bool? isCompleted,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
