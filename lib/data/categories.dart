import 'package:flutter/material.dart';
import 'package:stock_tracking_firebase/models/categories.dart';

const categories = {
  Categories.elektronik: Category(
    'Elektronik',
    Icons.phone_android, // Örnek olarak telefon ikonu
  ),
  Categories.gida: Category(
    'Gıda',
    Icons.restaurant, // Örnek olarak restoran ikonu
  ),
  Categories.giyim: Category(
    'Giyim',
    Icons.shopping_basket, // Örnek olarak alışveriş sepeti ikonu
  ),
  Categories.temizlik: Category(
    'Temizlik',
    Icons.cleaning_services, // Örnek olarak temizlik hizmetleri ikonu
  ),
  Categories.mobilya: Category(
    'Mobilya',
    Icons.weekend, // Örnek olarak hafta sonu ikonu
  ),
  Categories.kirtasiye: Category(
    'Kırtasiye',
    Icons.create, // Örnek olarak yazı yazma ikonu
  ),
  Categories.kozmetik: Category(
    'Kozmetik',
    Icons.face, // Örnek olarak yüz ikonu
  ),
  Categories.oyuncak: Category(
    'Oyuncak',
    Icons.toys, // Örnek olarak oyuncaklar ikonu
  ),
  Categories.saglik: Category(
    'Sağlık',
    Icons.local_hospital, // Örnek olarak hastane ikonu
  ),
  Categories.diger: Category(
    'Diğer',
    Icons.category, // Örnek olarak kategori ikonu
  ),
};