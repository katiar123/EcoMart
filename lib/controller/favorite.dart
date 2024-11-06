import 'package:shared_preferences/shared_preferences.dart';

class FavoriteController {
  Future<List<int>> getFavoriteIds() async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteIds = prefs.getStringList('favorite_ids') ?? [];
    return favoriteIds.map((id) => int.parse(id)).toList();
  }

  Future<void> addFavorite(int productId) async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteIds = prefs.getStringList('favorite_ids') ?? [];
    if (!favoriteIds.contains(productId.toString())) {
      favoriteIds.add(productId.toString());
      await prefs.setStringList('favorite_ids', favoriteIds);
    }
  }

  Future<void> removeFavorite(int productId) async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteIds = prefs.getStringList('favorite_ids') ?? [];
    favoriteIds.remove(productId.toString());
    await prefs.setStringList('favorite_ids', favoriteIds);
  }
}
