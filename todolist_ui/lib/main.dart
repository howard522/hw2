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

  // 每個 Todo 多了 "deadline" 欄位
  final List<Map<String, dynamic>> _todos = [
    {
      "title": "完成報告",
      "category": "工作",
      "isCompleted": false,
      "deadline": DateTime.now().subtract(const Duration(days: 1)), // 昨天
    },
    {
      "title": "買牛奶",
      "category": "購物",
      "isCompleted": false,
      "deadline": DateTime.now(), // 今天
    },
    {
      "title": "背英文單字",
      "category": "學習",
      "isCompleted": false,
      "deadline": DateTime.now().add(const Duration(days: 2)), // 後天
    },
    {
      "title": "買麵包",
      "category": "購物",
      "isCompleted": false,
      "deadline": DateTime.now(), // 今天
    },
    {
      "title": "買衣服",
      "category": "購物",
      "isCompleted": false,
      "deadline": DateTime.now().add(const Duration(days: 3)), // 今天
    },
    {
      "title": "買電腦",
      "category": "購物",
      "isCompleted": false,
      "deadline": DateTime.now().add(const Duration(days: 3)), // 今天
    },
    // 你也可以加入更多測試資料
  ];

  final TextEditingController _todoController = TextEditingController();
  String _selectedCategory = "所有";

  // 底部導覽列當前選擇的索引
  int _selectedIndex = 0;

  // 三個區段的收合狀態
  bool _showPast = true; // 以前的
  bool _showToday = true; // 今天
  bool _showFuture = true; // 未來

  // 產生新增 Todo 的對話框
  void _addTodoDialog() {
    DateTime? _selectedDeadline;
    showDialog(
      context: context,
      builder: (context) {
        String tempCategory = categories[0];
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("新增代辦事項"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _todoController,
                      decoration: const InputDecoration(hintText: "輸入代辦事項"),
                    ),
                    const SizedBox(height: 10),
                    DropdownButton<String>(
                      value: tempCategory,
                      items:
                          categories.map((String category) {
                            return DropdownMenuItem<String>(
                              value: category,
                              child: Text(category),
                            );
                          }).toList(),
                      onChanged: (String? newValue) {
                        setStateDialog(() {
                          tempCategory = newValue!;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    // 選擇截止日期
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("截止日期："),
                        Text(
                          _selectedDeadline == null
                              ? "未選擇"
                              : "${_selectedDeadline!.year}-${_selectedDeadline!.month.toString().padLeft(2, '0')}-${_selectedDeadline!.day.toString().padLeft(2, '0')}",
                        ),
                        IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () async {
                            final pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                            );
                            if (pickedDate != null) {
                              setStateDialog(() {
                                _selectedDeadline = pickedDate;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
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
                          "category": tempCategory,
                          "isCompleted": false,
                          "deadline": _selectedDeadline, // 可能是null
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
      },
    );
  }

  // 底部導覽列被點擊時
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // 這裡可以根據 index 來切換頁面或做其他邏輯
  }

  @override
  Widget build(BuildContext context) {
    // 先依照當前選擇的分類做篩選 (若 _selectedCategory == "所有" 就不篩選)
    final filteredTodos =
        _selectedCategory == "所有"
            ? _todos
            : _todos
                .where((todo) => todo["category"] == _selectedCategory)
                .toList();

    // 接著依照當前日期做分組
    final now = DateTime.now();
    // 只要比較「日期」部分 (忽略時、分、秒)
    final today = DateTime(now.year, now.month, now.day);

    // 用三個清單分別存放「以前的、今天、未來」
    List<Map<String, dynamic>> pastTodos = [];
    List<Map<String, dynamic>> todayTodos = [];
    List<Map<String, dynamic>> futureTodos = [];

    for (var todo in filteredTodos) {
      final deadline = todo["deadline"];
      // 如果沒設定 deadline，就直接歸類到「未來」(你也可以改成其它邏輯)
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

    // 建立一個用於顯示 "List<Map<String, dynamic>>" 的小型 widget
    Widget buildTodoList(List<Map<String, dynamic>> todos) {
      return Column(
        children:
            todos.map((todo) {
              // 顯示 deadline (若為 null 則顯示「無」)
              String deadlineText = "無";
              if (todo["deadline"] != null) {
                final d = todo["deadline"] as DateTime;
                deadlineText =
                    "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
              }

              return ListTile(
                leading: Checkbox(
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
                    decoration:
                        todo["isCompleted"] ? TextDecoration.lineThrough : null,
                  ),
                ),
                subtitle: Text("${todo["category"]} | 截止：$deadlineText"),
                trailing: IconButton(
                  icon: const Icon(Icons.flag),
                  onPressed: () {
                    setState(() {
                      _todos.remove(todo);
                    });
                  },
                ),
              );
            }).toList(),
      );
    }

    // 做三個小區塊：以前的 / 今天 / 未來
    // 用一個 Row + IconButton(或 GestureDetector) 來做「箭頭收合 / 展開」
    Widget buildCollapsibleSection({
      required String title,
      required bool isExpanded,
      required VoidCallback onTap,
      required List<Map<String, dynamic>> data,
    }) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 標題列 + 箭頭
          GestureDetector(
            onTap: onTap,
            child: Row(
              children: [
                Icon(
                  // 如果目前是展開，就用 arrow_drop_down，否則用 arrow_right
                  isExpanded ? Icons.arrow_drop_down : Icons.arrow_right,
                ),
                Text(title, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
          // 若 isExpanded = true，則顯示清單；否則不顯示
          if (isExpanded) buildTodoList(data),
          // 分隔
          const Divider(),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("To-Do List"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 分類列
          const SizedBox(height: 10),
          SizedBox(
            height: 35,
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
          const SizedBox(height: 10),

          // 使用 SingleChildScrollView + Column 來容納三個收合區塊
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

      // 浮動按鈕
      floatingActionButton: FloatingActionButton(
        onPressed: _addTodoDialog,
        child: const Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
      ),

      // 底部導覽列
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: "三條線"),
          BottomNavigationBarItem(icon: Icon(Icons.check_box), label: "任務"),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: "日曆",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "我的"),
        ],
      ),
    );
  }
}
