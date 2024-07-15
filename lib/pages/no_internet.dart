import 'package:flutter/material.dart';


class NoInternetScreen extends StatelessWidget {
  const NoInternetScreen({super.key});

  @override
  Widget build(context) {
    return const MaterialApp(
      home: Scaffold(
        body: Padding(padding: EdgeInsets.all(12),child: Column(
          children: [
            Icon(Icons.signal_wifi_connected_no_internet_4_outlined),
            Center(child: Text("İnternet Bağlantısı Yok..."),)
          ],
        ),)
      ),
    );
  }
}