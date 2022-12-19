import 'dart:convert' as convert;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List items = <dynamic> [];

  @override
  void initState(){
    super.initState();
    getTodos();
  }

  Future <void> getTodos() async {
    final url = Uri.parse('https://jsonplaceholder.typicode.com/posts');
    final response = await http.get(url);

    setState(() {
      items = convert.jsonDecode(response.body) as List;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Todo List"),
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index){
          final item = items[index] as Map;
          return Dismissible(
            key: ValueKey(item[index]),
            background: slideLeftBackground(),
            confirmDismiss: (direction) async {
              if (direction == DismissDirection.endToStart) {
                final bool response = await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        content: Text(
                            "Do you want to delete\n${items[index]['title']}?"),
                        actions: <Widget>[
                          FloatingActionButton(
                            child: const Text(
                              "Cancel",
                              style: TextStyle(color: Colors.black),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          FloatingActionButton(
                            child: const Text(
                              "Delete",
                              style: TextStyle(color: Colors.red),
                            ),
                            onPressed: () {
                              setState(() {
                                items.removeAt(index);
                              });
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    });
                return response;
              }
              return null;
            },
            child: ListTile(
                leading: Text('${index + 1}',style : const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold
                ), ),
                title: Text(items[index]['title'],
                  style : const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(items[index]['body'],
                  style : const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold
                  ),),

            ),
          );
        },
      ),

    );
  }

  Widget slideLeftBackground() {
    return Container(
      color: Colors.red,
      child: Align(
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: const <Widget>[
            Text(
              " Delete",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.right,
            ),
            SizedBox(
              width: 20,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> deleteTodo(String id) async {
    final url = Uri.parse('https://jsonplaceholder.typicode.com/posts/$id');
    final response = await http.delete(url);

    if (response.statusCode == 200) {
      final filtered = items.where((e) => e['_id'] != id).toList();
      setState(() {
        items = filtered;
      });
    }
    getTodos();
  }






}
