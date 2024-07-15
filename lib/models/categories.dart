import 'package:flutter/material.dart';

enum Categories {
  elektronik,
  gida,
  giyim,
  temizlik,
  mobilya,
  kirtasiye,
  kozmetik,
  oyuncak,
  saglik,
  diger
}

class Category {
  const Category(this.title, this.icon);

  final String title;
  final IconData icon;
}
