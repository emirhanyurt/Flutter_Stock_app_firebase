import 'package:stock_tracking_firebase/models/categories.dart';

class StockItem {
  const StockItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.category,
  });

  final String id;
  final String name;
  final int quantity;
  final Category category;
}