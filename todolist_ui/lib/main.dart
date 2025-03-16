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
      home: const TodoListScreen(),
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
      "deadline": DateTime.now().add(const Duration(days: 3)), // 未來
    },
    {
      "title": "買電腦",
      "category": "購物",
      "isCompleted": false,
      "deadline": DateTime.now().add(const Duration(days: 3)), // 未來
    },
  ];

  // 文字輸入控制
  final TextEditingController _todoController = TextEditingController();

  // 當前選取的分類
  String _selectedCategory = "所有";

  // BottomNavigationBar 當前選取的索引 (0-based)
  // 預設選到索引 1 => 「任務」
  int _selectedIndex = 1;

  // 三個區段(以前的/今天/未來)是否收合
  bool _showPast = true;
  bool _showToday = true;
  bool _showFuture = true;

  // 新增代辦事項對話框
  void _addTodoDialog() {
    DateTime? _selectedDeadline;
    showDialog(
      context: context,
      builder: (context) {
        String tempCategory = categories[0]; // 對話框內的暫存分類
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("新增代辦事項"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 輸入文字
                    TextField(
                      controller: _todoController,
                      decoration: const InputDecoration(hintText: "輸入代辦事項"),
                    ),
                    const SizedBox(height: 10),
                    // 選擇分類
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
                    // 選截止日期
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("截止日期："),
                        Text(
                          _selectedDeadline == null
                              ? "未選擇"
                              : "${_selectedDeadline!.year}"
                                  "-${_selectedDeadline!.month.toString().padLeft(2, '0')}"
                                  "-${_selectedDeadline!.day.toString().padLeft(2, '0')}",
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
  }

  // 生成代辦清單
  Widget buildTodoList(List<Map<String, dynamic>> todos) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return Column(
      children:
          todos.map((todo) {
            // 只顯示 "MM-DD"
            String deadlineText = "無";
            // 若過去日期 => 紅色
            Color dateColor = Colors.black;

            final deadline = todo["deadline"] as DateTime?;
            if (deadline != null) {
              deadlineText =
                  "${deadline.month.toString().padLeft(2, '0')}-${deadline.day.toString().padLeft(2, '0')}";

              final compareDate = DateTime(
                deadline.year,
                deadline.month,
                deadline.day,
              );
              if (compareDate.isBefore(today)) {
                dateColor = Colors.red;
              }
            }

            return Container(
              // 在每個 ListTile 外包一層 Container
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              decoration: BoxDecoration(
                color: Color.fromRGBO(245, 248, 248, 1), // 淺灰背景
                borderRadius: BorderRadius.circular(8), // 圓角
              ),
              child: ListTile(
                // 圓形 Checkbox
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
                    decoration:
                        todo["isCompleted"] ? TextDecoration.lineThrough : null,
                  ),
                ),
                subtitle: Text(
                  deadlineText,
                  style: TextStyle(color: dateColor),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.flag),
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

  // 生成收合區塊 (以前的 / 今天 / 未來)
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
    // 依據 _selectedCategory 做篩選
    final filteredTodos =
        _selectedCategory == "所有"
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
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color:
                                _selectedCategory == category
                                    ? Color.fromRGBO(140, 181, 245, 1)
                                    : Color.fromRGBO(226, 238, 254, 1),
                          ),
                          child: Center(
                            child: Text(
                              category,
                              style: TextStyle(
                                fontSize: 16,
                                color:
                                    _selectedCategory == category
                                        ? Colors.white
                                        : Color.fromRGBO(154, 163, 175, 1),
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

      // 底部導覽列 (帶有紅點 + 預設選到第二個)
      bottomNavigationBar: BottomNavigationBar(
        // 讓未選中的 label 也顯示
        type: BottomNavigationBarType.fixed,
        // 選中的 icon/label 顯示的顏色 (此處設定為藍色)
        selectedItemColor: Colors.blue,
        // 未選中的 icon/label 顯示的顏色 (灰色)
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            // 用 Stack 疊加「漢堡 icon + 左上紅點」
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
            // 若不想要文字，可將 label 改為空字串: label: '',
            label: '',
          ),
          BottomNavigationBarItem(icon: const Icon(Icons.article), label: '任務'),
          BottomNavigationBarItem(
            icon: const Icon(Icons.calendar_month),
            label: '日曆',
          ),
          BottomNavigationBarItem(icon: const Icon(Icons.person), label: '我的'),
        ],
      ),
    );
  }
}
