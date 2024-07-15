import 'dart:convert';

import 'package:flutter/material.dart';

//import 'package:shopping_app/models/grocery_item.dart';
import 'package:http/http.dart' as http;
import 'package:localstorage/localstorage.dart';
import 'package:stock_tracking_firebase/data/categories.dart';
import 'package:stock_tracking_firebase/firebase_config.dart';
import 'package:stock_tracking_firebase/models/categories.dart';
import 'package:stock_tracking_firebase/models/stock.dart';

class NewStock extends StatefulWidget {
  NewStock({required this.groceryItems, super.key});
  List<StockItem> groceryItems;
  @override
  State<NewStock> createState() {
    return _NewStockState();
  }
}

class _NewStockState extends State<NewStock> {
  final _formKey = GlobalKey<FormState>();
  var _enteredName = '';
  var _enteredQuantity = 1;
  var email = localStorage.getItem('email');
  var _selectedCategory = categories[Categories.gida]!;
  var isSending = false;

  void _saveItem() async {
    var doNotSave = false;
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        isSending = true;
      });
      for (var i = 0; i < widget.groceryItems.length; i++) {
        if (_enteredName == widget.groceryItems[i].name) {
          doNotSave = true;
        }
      }

      if (doNotSave == false) {
        final url = Uri.https(firebaseApiKey, 'stock-list.json');
        final response = await http.post(url,
            headers: {
              'Content-Type': 'application/json',
            },
            body: json.encode({
              'name': _enteredName,
              'quantity': _enteredQuantity,
              'category': _selectedCategory.title,
              'email': email
            }));

        final Map<String, dynamic> resData = json.decode(response.body);
        if (!context.mounted) {
          return;
        }
        Navigator.of(context).pop(StockItem(
            id: resData['name'],
            name: _enteredName,
            quantity: _enteredQuantity,
            category: _selectedCategory));
      } else {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar( SnackBar(
          content: Text(
              '${_enteredName} isimli ürün zaten stoklarınızda mevcuttur'),
          backgroundColor: Colors.red,
        ));
        isSending = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Ürün Ekle'),
      ),
      body: Padding(
          padding: const EdgeInsets.all(12),
          child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    maxLength: 50,
                    decoration: const InputDecoration(label: Text('Ürün Adı')),
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          value.trim().length <= 1 ||
                          value.trim().length > 30) {
                        return 'Email en fazla 30 karakter olabilir.';
                      }

                      return null;
                    },
                    onSaved: (newValue) {
                      _enteredName = newValue!;
                    },
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                          child: TextFormField(
                        decoration: const InputDecoration(
                          label: Text('Adet'),
                        ),
                        initialValue: '1',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              int.tryParse(value) == null ||
                              int.tryParse(value)! <= 0) {
                            return 'Sadece 0 dan büyük sayı girebilirsiniz';
                          }

                          return null;
                        },
                        onSaved: (newValue) {
                          _enteredQuantity = int.parse(newValue!);
                        },
                      )),
                      const SizedBox(width: 8),
                      Expanded(
                          child: DropdownButtonFormField(
                        value: _selectedCategory,
                        items: [
                          for (final category in categories.entries)
                            DropdownMenuItem(
                                value: category.value,
                                child: Row(
                                  children: [
                                    Icon(category.value.icon),
                                    const SizedBox(
                                      width: 6,
                                    ),
                                    Text(category.value.title)
                                  ],
                                ))
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value!;
                          });
                        },
                      ))
                    ],
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                          onPressed: isSending
                              ? null
                              : () {
                                  _formKey.currentState!.reset();
                                },
                          child: const Text('Sıfırla')),
                      ElevatedButton(
                          onPressed: isSending ? null : _saveItem,
                          child: isSending
                              ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(),
                                )
                              : const Text('Kaydet'))
                    ],
                  )
                ],
              ))),
    );
  }
}
