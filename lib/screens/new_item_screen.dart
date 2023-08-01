import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shoplistapp/data/categories.dart';
import 'package:shoplistapp/models/groceryitem.dart';

import '../models/category.dart';

class NewItemScreen extends StatefulWidget {
  const NewItemScreen({super.key});

  @override
  State<NewItemScreen> createState() => _NewItemScreenState();
}

class _NewItemScreenState extends State<NewItemScreen> {
  final _formKey = GlobalKey<FormState>();
  var _enteredItemName = '';
  var _enteredQuantity = 1;
  var _enteredCategory = categories[Categories.vegetables];
  var _isSendingData = false;

  // make function async
  void _saveItem() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _isSendingData = true;
    });
    final url =
        Uri.https('aegis-c54d9-default-rtdb.firebaseio.com', '/items.json');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(
        {
          'name': _enteredItemName,
          'quantity': _enteredQuantity,
          'category': _enteredCategory!.name,
        },
      ),
    );

    final jsonBody = json.decode(response.body);

    if (context.mounted) {
      Navigator.of(context).pop(
        GroceryItem(
          id: jsonBody['name'],
          name: _enteredItemName,
          quantity: _enteredQuantity,
          category: _enteredCategory!,
        ),
      );
    }
    // Navigator.of(context).pop(
    //   GroceryItem(
    //     id: DateTime.now().toString(),
    //     name: _enteredItemName,
    //     quantity: _enteredQuantity,
    //     category: _enteredCategory!,
    //   ),
    // );
  }

  void _resetForm() {
    _formKey.currentState!.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length <= 1 ||
                      value.trim().length >= 50) {
                    return 'Please enter item name between 2 and 50 characters';
                  }
                  return null;
                },
                onSaved: (value) {
                  _enteredItemName = value!;
                },
                initialValue: _enteredItemName,
                decoration: const InputDecoration(labelText: 'Item Name'),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == null ||
                            int.tryParse(value)! <= 0) {
                          return 'Please enter a valid, positive number';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        _enteredQuantity = int.parse(value);
                      },
                      initialValue: _enteredQuantity.toString(),
                      decoration: const InputDecoration(labelText: 'Quantity'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: DropdownButtonFormField(
                      value: _enteredCategory,
                      decoration:
                          const InputDecoration(labelText: 'Item Category'),
                      items: [
                        for (final category in categories.entries)
                          DropdownMenuItem(
                            value: category.value,
                            child: Row(
                              children: [
                                Container(
                                  height: 16,
                                  width: 16,
                                  color: category.value.color,
                                ),
                                const SizedBox(
                                  width: 6,
                                ),
                                Text(category.value.name.replaceFirst(
                                    category.value.name[0],
                                    category.value.name[0].toUpperCase())),
                              ],
                            ),
                          ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _enteredCategory = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 24,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSendingData ? null : _resetForm,
                    child: const Text('Reset'),
                  ),
                  ElevatedButton(
                    onPressed: _isSendingData ? null : _saveItem,
                    child: _isSendingData
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator())
                        : const Text('Add Item'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
