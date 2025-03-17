import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

/// 1) 最上層App
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SafeArea(child: TodoListScreen()),
    );
  }
}

/// 2) 主畫面 (Stateful)
class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  // 分類清單
  final List<String> categories = [
    "所有",
    "工作",
    "個人",
    "願望清單",
    "學習",
    "購物",
    "運動",
    "旅行",
    "健康",
    "其他",
  ];

  // 代辦事項（示例用）
  final List<Map<String, dynamic>> _todos = [
    {
      "title": "完成報告",
      "category": "工作",
      "isCompleted": false,
      "deadline": DateTime.now().subtract(const Duration(days: 1)),
    },
    {
      "title": "買牛奶",
      "category": "購物",
      "isCompleted": false,
      "deadline": DateTime.now(),
    },
    {
      "title": "買豆漿",
      "category": "購物",
      "isCompleted": false,
      "deadline": DateTime.now(),
    },
    {
      "title": "背英文單字",
      "category": "學習",
      "isCompleted": false,
      "deadline": DateTime.now().add(const Duration(days: 2)),
    },
    {
      "title": "買麵包",
      "category": "購物",
      "isCompleted": false,
      "deadline": DateTime.now(),
    },
    {
      "title": "買衣服",
      "category": "購物",
      "isCompleted": false,
      "deadline": DateTime.now().add(const Duration(days: 3)),
    },
    {
      "title": "買電腦",
      "category": "購物",
      "isCompleted": false,
      "deadline": DateTime.now().add(const Duration(days: 3)),
    },
  ];

  final TextEditingController _todoController = TextEditingController();

  String _selectedCategory = "所有";

  int _selectedIndex = 1;

  bool _showPast = true;
  bool _showToday = true;
  bool _showFuture = true;

  // 新增代辦事項對話框
  void _addTodoDialog() {
    // 可根據需求實作新增代辦事項對話框
  }

  // 底部導覽列被點擊時
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget buildTodoList(List<Map<String, dynamic>> todos) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return Column(
      children: todos.map((todo) {
        String deadlineText = "無";
        Color dateColor = Colors.black;

        final deadline = todo["deadline"] as DateTime?;
        if (deadline != null) {
          final compareDate =
              DateTime(deadline.year, deadline.month, deadline.day);
          // 如果日期為今天，不顯示日期
          if (compareDate.isAtSameMomentAs(today)) {
            deadlineText = "";
          } else {
            deadlineText =
                "${deadline.month.toString().padLeft(2, '0')}-${deadline.day.toString().padLeft(2, '0')}";
          }

          if (compareDate.isBefore(today)) {
            dateColor = Colors.red;
          }
        }

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(245,248,253, 1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            leading: Checkbox(
              shape: const CircleBorder(),
              value: todo["isCompleted"],
              onChanged: (value) {
                setState(() {
                  todo["isCompleted"] = value!;
                });
              },
            ),
            title: Text(
              todo["title"],
              style: TextStyle(
                decoration: todo["isCompleted"]
                    ? TextDecoration.lineThrough
                    : null,
              ),
            ),
            subtitle: Text(
              deadlineText,
              style: TextStyle(color: dateColor),
            ),
            trailing: IconButton(
              icon: Image.asset('assets/flag_icon.png'),
              onPressed: () {
                setState(() {
                  _todos.remove(todo);
                });
              },
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget buildCollapsibleSection({
    required String title,
    required bool isExpanded,
    required VoidCallback onTap,
    required List<Map<String, dynamic>> data,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 抬頭 + 箭頭 (左)
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Row(
            children: [
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 4),
              Icon(isExpanded ? Icons.arrow_drop_up : Icons.arrow_right),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // 若展開 => 顯示清單
        if (isExpanded) buildTodoList(data),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredTodos = _selectedCategory == "所有"
        ? _todos
        : _todos
            .where((todo) => todo["category"] == _selectedCategory)
            .toList();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 分三類
    List<Map<String, dynamic>> pastTodos = [];
    List<Map<String, dynamic>> todayTodos = [];
    List<Map<String, dynamic>> futureTodos = [];

    for (var todo in filteredTodos) {
      final deadline = todo["deadline"] as DateTime?;
      if (deadline == null) {
        futureTodos.add(todo);
      } else {
        final d = DateTime(deadline.year, deadline.month, deadline.day);
        if (d.isBefore(today)) {
          pastTodos.add(todo);
        } else if (d.isAtSameMomentAs(today)) {
          todayTodos.add(todo);
        } else {
          futureTodos.add(todo);
        }
      }
    }

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 分類列
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: categories.map((category) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCategory = category;
                            });
                          },
                          child: Container(
                            margin:
                                const EdgeInsets.symmetric(horizontal: 10),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: _selectedCategory == category
                                  ? const Color.fromRGBO(140, 181, 245, 1)
                                  : const Color.fromRGBO(226, 238, 254, 1),
                            ),
                            child: Center(
                              child: Text(
                                category,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: _selectedCategory == category
                                      ? Colors.white
                                      : const Color.fromRGBO(154, 163, 175, 1),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {
                    // 可在此處加入更多的操作
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // 三個收合區塊
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  buildCollapsibleSection(
                    title: "以前的",
                    isExpanded: _showPast,
                    onTap: () {
                      setState(() {
                        _showPast = !_showPast;
                      });
                    },
                    data: pastTodos,
                  ),
                  buildCollapsibleSection(
                    title: "今天",
                    isExpanded: _showToday,
                    onTap: () {
                      setState(() {
                        _showToday = !_showToday;
                      });
                    },
                    data: todayTodos,
                  ),
                  buildCollapsibleSection(
                    title: "未來",
                    isExpanded: _showFuture,
                    onTap: () {
                      setState(() {
                        _showFuture = !_showFuture;
                      });
                    },
                    data: futureTodos,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      // 浮動按鈕 (圓形)
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        backgroundColor: Colors.blueAccent,
        onPressed: _addTodoDialog,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.menu),
                Positioned(
                  top: 0,
                  left: 18,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            label: '',
          ),
          BottomNavigationBarItem(
              icon: const Icon(Icons.article), label: '任務'),
          BottomNavigationBarItem(
            icon: const Icon(Icons.calendar_month),
            label: '日曆',
          ),
          BottomNavigationBarItem(
              icon: const Icon(Icons.person), label: '我的'),
        ],
      ),
    );
  }
}
