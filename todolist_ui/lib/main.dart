import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TodoListScreen(),
    );
  }
}

class TodoListScreen extends StatefulWidget {
  TodoListScreen({super.key});

  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final List<String> categories = [
    "所有",
    "工作",
    "個人",
    "學習",
    "購物",
    "運動",
    "旅行",
    "健康",
    "其他",
  ];

  // 儲存代辦事項的列表
  final List<Map<String, dynamic>> _todos = [
    {"title": "完成報告", "category": "工作", "isCompleted": false},
    {"title": "買牛奶", "category": "購物", "isCompleted": false},
  ];

  final TextEditingController _todoController = TextEditingController();
  String _selectedCategory = "所有";

  // 新增代辦事項的對話框
  void _addTodoDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String selectedCategory = categories[0];
        return AlertDialog(
          title: const Text("新增代辦事項"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _todoController,
                decoration: const InputDecoration(hintText: "輸入代辦事項"),
              ),
              const SizedBox(height: 10),
              DropdownButton<String>(
                value: selectedCategory,
                items:
                    categories.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedCategory = newValue!;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("取消"),
            ),
            TextButton(
              onPressed: () {
                if (_todoController.text.isNotEmpty) {
                  setState(() {
                    _todos.add({
                      "title": _todoController.text,
                      "category": selectedCategory,
                      "isCompleted": false,
                    });
                    _todoController.clear();
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text("新增"),
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
        title: const Text("To-Do List"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 分類列
          SizedBox(
            height: 50,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children:
                    categories.map((category) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.blueAccent),
                            color:
                                _selectedCategory == category
                                    ? Colors.blueAccent
                                    : Colors.white,
                          ),
                          child: Center(
                            child: Text(
                              category,
                              style: TextStyle(
                                fontSize: 16,
                                color:
                                    _selectedCategory == category
                                        ? Colors.white
                                        : Colors.blueAccent,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),
          ),
          // 代辦事項列表
          Expanded(
            child: ListView.builder(
              itemCount: _todos.length,
              itemBuilder: (context, index) {
                final todo = _todos[index];
                if (_selectedCategory == "所有" ||
                    todo["category"] == _selectedCategory) {
                  return ListTile(
                    leading: Checkbox(
                      value: todo["isCompleted"],
                      onChanged: (value) {
                        setState(() {
                          _todos[index]["isCompleted"] = value!;
                        });
                      },
                    ),
                    title: Text(
                      todo["title"],
                      style: TextStyle(
                        decoration:
                            todo["isCompleted"]
                                ? TextDecoration.lineThrough
                                : null,
                      ),
                    ),
                    subtitle: Text(todo["category"]),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          _todos.removeAt(index);
                        });
                      },
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTodoDialog,
        child: const Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }
}
