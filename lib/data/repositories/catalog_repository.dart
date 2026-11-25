import '../../domain/models/menu_product.dart';

abstract interface class CatalogRepository {
  Future<List<MenuProduct>> loadMenu();
}
