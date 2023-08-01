import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shoplistapp/models/groceryitem.dart';
import 'package:shoplistapp/widgets/grocery_item_tile.dart';

import '../data/categories.dart';
import 'new_item_screen.dart';

class InitScreen extends StatefulWidget {
  const InitScreen({super.key});

  @override
  State<InitScreen> createState() => _InitScreenState();
}

class _InitScreenState extends State<InitScreen> {
  late List<GroceryItem> _groceryItems = [];
  var _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  // we can avoid an unecessary request by passing the grociery item to the new item screen pop

  void _loadItems() async {
    final url =
        Uri.https('aegis-c54d9-default-rtdb.firebaseio.com', '/items.json');

    try {
      final response = await http.get(url);

      if (response.statusCode >= 400) {
        setState(() {
          _errorMessage = 'Something went wrong!';
        });
        return;
      }

      if (response.body == 'null') {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final Map<String, dynamic> listData = json.decode(response.body);

      final List<GroceryItem> loadedItems = [];
      for (final item in listData.entries) {
        final category = categories.entries
            .firstWhere((element) => element.value.name == item.value['category'])
            .value;
        final itemToAdd = GroceryItem(
          id: item.key,
          name: item.value['name'],
          quantity: item.value['quantity'],
          category: category,
        );
        loadedItems.add(itemToAdd);
      }

      setState(() {
        _groceryItems = loadedItems;
        _isLoading = false;
      });
    }
    catch (e) {
      setState(() {
        _errorMessage = 'Something went wrong! Please try again later.';
      });
      return;
    }


    // with for each
    // listData.forEach((key, data) {
    //   final item = GroceryItem(
    //     id: key,
    //     name: data['name'],
    //     quantity: data['quantity'],
    //     category: data['category'],
    //   );
    //   setState(() {
    //     _groceryItems.add(item);
    //   });
    // });
  }

  // ussing async and await to get the data from the new item screen
  void _addItem() async {
    // // final newItem =
    // await Navigator.of(context).push<GroceryItem>(
    //   MaterialPageRoute(
    //     builder: (context) => const NewItemScreen(),
    //   ),
    // );
    // // unessesary request
    // // _loadItems();
    // //

    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (context) => const NewItemScreen(),
      ),
    );

    if (newItem == null) {
      return;
    }
    setState(() {
      _groceryItems.add(newItem);
    });
  }

  //   if (newItem == null) {
  //     return;
  //   }
  //
  //   setState(() {
  // //     _groceryItems.add(newItem);
  // //   });
  //
  // }

  void _removeItem(GroceryItem item) async {
    final index = _groceryItems.indexOf(item);
    setState(() {
      _groceryItems.remove(item);
    });

    final url = Uri.https(
        'aegis-c54d9-default-rtdb.firebaseio.com', '/items/${item.id}.json');

    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      //show a snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not delete item, try again later.'),
        ),
      );
      setState(() {
        _groceryItems.insert(index, item);
      });

      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget contentBody = const Center(
      child: Text('No Groceries added yet!'),
    );

    if (_isLoading) {
      contentBody = const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      contentBody = Center(
        child: Text(_errorMessage!),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groceries'),
        actions: [
          IconButton(
            onPressed: _addItem,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: _groceryItems.isEmpty
          ? contentBody
          : ListView.builder(
              itemCount: _groceryItems.length,
              itemBuilder: (BuildContext context, int index) {
                final GroceryItem item = _groceryItems[index];
                return Dismissible(
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    child: const Padding(
                      padding: EdgeInsets.only(right: 8.0),
                      child: Icon(
                        Icons.delete,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                  key: Key(item.id),
                  onDismissed: (direction) {
                    _removeItem(item);
                  },
                  child: ShopItemTile(
                    title: item.name,
                    color: item.category.color,
                    amount: item.quantity,
                  ),
                );
              }),
    );
  }
}
