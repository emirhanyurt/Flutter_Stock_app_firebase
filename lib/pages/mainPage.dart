import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:stock_tracking_firebase/data/categories.dart';
import 'package:stock_tracking_firebase/models/stock.dart';
import 'package:stock_tracking_firebase/pages/login_screen.dart';

import 'package:stock_tracking_firebase/pages/new_stock.dart';
import 'package:http/http.dart' as http;

import '../firebase_config.dart';

class Mainpage extends StatefulWidget {
  const Mainpage({super.key});

  @override
  State<Mainpage> createState() {
    return _MainpageState();
  }
}

class _MainpageState extends State<Mainpage> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final email = localStorage.getItem('email');
  List<StockItem> _groceryItems = [];
  var isLoading = true;
  int newQuantity = 0;
  String? error;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _loadItems();
    _searchController.addListener(_updateSearchQuery);
  }

  void _updateSearchQuery() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  void updateStock(StockItem item, ctx) async {
    final url = Uri.https(firebaseApiKey, 'stock-list/${item.id}.json');
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'name': item.name,
        'quantity': newQuantity,
        'category': item.category.title,
        'email': email,
      }),
    );

    if (response.statusCode == 200) {
      _loadItems(); // Verileri yeniden yükle
      Navigator.of(ctx).pop();
      if (newQuantity == 0) {
        _showAlertDialog(context, item);
      }
    } else {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Güncelleme sırasında bir hata oluştu"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future _showAlertDialog(BuildContext context, StockItem item) => showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: Text('Uyarı'),
            content:
                Text('${item.name} isimli üründen 0 adet kalmıştır. Ürünü silmek ister misiniz?'),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    child: const Text('Hayır'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  ElevatedButton(
                    child: const Text('Evet'),
                    onPressed: () async {
                      await _removeItem(item);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      );

  void _loadItems() async {
    try {
      final url = Uri.https(firebaseApiKey, 'stock-list.json');
      final response = await http.get(url);

      if (response.body == 'null') {
        setState(() {
          isLoading = false;
        });
        return;
      }
      final Map<String, dynamic> listData = json.decode(response.body);
      final List<StockItem> loadedItems = [];

      for (final item in listData.entries) {
        final category = categories.entries
            .firstWhere(
                (element) => element.value.title == item.value['category'])
            .value;
        if (item.value['email'] == email) {
          loadedItems.add(StockItem(
              id: item.key,
              name: item.value['name'],
              quantity: item.value['quantity'],
              category: category));
        }
      }
      setState(() {
        _groceryItems = loadedItems;
        isLoading = false;
      });
    } catch (_error) {
      setState(() {
        error = 'Failed to fetch data.';
      });
    }
  }

  void _addItem() async {
    final newItem =
        await Navigator.of(context).push<StockItem>(MaterialPageRoute(
      builder: (ctx) =>  NewStock(groceryItems: _groceryItems,),
    ));
    if (newItem == null) {
      return;
    }
    setState(() {
      _groceryItems.add(newItem);
    });
  }

  void out() async {
    await _firebaseAuth.signOut();
    localStorage.clear();
    Navigator.pop(context);
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const LoginScreen()));
  }

  Future<void> _removeItem(StockItem item) async {
    final url = Uri.https(firebaseApiKey, 'stock-list/${item.id}.json');
    final response = await http.delete(url);

    if (response.statusCode >= 400) {
     ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Silme işlemi sırasında bir hara oluştu"),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      _loadItems(); // Stokları yeniden yükle
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Padding(
      padding: const EdgeInsets.all(18.0),
      child: Column(
        children: [
          const Expanded(
            child: Center(
              child: Text('Kayıtlı Stok bulunamadı'),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(onPressed: _addItem, child: const Text('Stok Ekle')),
            ],
          ),
        ],
      ),
    );

    if (isLoading) {
      content = const Center(child: CircularProgressIndicator());
    }
    if (_groceryItems.isNotEmpty) {
      content = Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Ara',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 20,),
            Expanded(
              child: ListView.builder(
                itemCount: _groceryItems.length,
                itemBuilder: (ctx, index) {
                  final item = _groceryItems[index];
                  if (_searchQuery.isEmpty ||
                      item.name.toLowerCase().contains(_searchQuery)) {
                    return Dismissible(
                      onDismissed: (direction) {
                        _removeItem(item);
                      },
                      key: ValueKey(item.id),
                      background: Container(color: Colors.red),
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 5.0),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.onInverseSurface,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          textColor: item.quantity >= 0 &&
                                  item.quantity <= 5
                              ? Colors.red
                              : Colors.black,
                          title: Text(
                            item.name,
                            style: const TextStyle(fontSize: 20),
                          ),
                          leading: Icon(
                            item.category.icon,
                            size: 35,
                            color: item.quantity >= 0 &&
                                    item.quantity <= 5
                                ? Colors.red
                                : Colors.black,
                          ),
                          trailing: Text(
                            item.quantity.toString(),
                            style: const TextStyle(fontSize: 20),
                          ),
                          onTap: () {
                            newQuantity = item.quantity;
                            showModalBottomSheet(
                              context: context,
                              builder: (ctx) => StatefulBuilder(
                                builder: (BuildContext context, StateSetter setState) {
                                  return SizedBox(
                                    width: double.infinity,
                                    height: 400,
                                    child: Padding(
                                      padding: const EdgeInsets.all(18.0),
                                      child: Column(
                                        children: [
                                          Text(
                                            item.name,
                                            style: const TextStyle(fontSize: 60.0),
                                          ),
                                          const SizedBox(height: 56),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              IconButton(
                                                onPressed: () {
                                                  setState(() {
                                                    if (newQuantity >= 0) {
                                                      newQuantity--;
                                                    }
                                                  });
                                                },
                                                icon: const Icon(Icons.remove),
                                                iconSize: 55,
                                              ),
                                              Text(
                                                '$newQuantity',
                                                style: const TextStyle(fontSize: 50),
                                              ),
                                              IconButton(
                                                onPressed: () {
                                                  setState(() {
                                                    newQuantity++;
                                                  });
                                                },
                                                icon: const Icon(Icons.add),
                                                iconSize: 55,
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 50),
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(ctx).pop();
                                                },
                                                child: const Text('İptal'),
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  updateStock(item, ctx);
                                                },
                                                child: const Text('Kaydet'),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  } else {
                    return Container();
                  }
                },
              ),
            ),
            ElevatedButton(onPressed: _addItem, child: const Text('Stok Ekle')),
          ],
        ),
      );
    }
    if (error != null) {
      content = Center(child: Text(error!));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stoklarınız'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(onPressed: out, icon: const Icon(Icons.logout_outlined)),
        ],
      ),
      body: content,
    );
  }
}
