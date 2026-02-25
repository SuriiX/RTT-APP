import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tipos de contenido que se pueden marcar como favorito.
enum FavoriteType { noticia, evento }

/// Servicio de favoritos con persistencia local via SharedPreferences.
/// Implementa ChangeNotifier para que los widgets se actualicen reactivamente.
class FavoritesService extends ChangeNotifier {
  FavoritesService._();
  static final FavoritesService instance = FavoritesService._();

  static const _keyNoticias = 'fav_noticias';
  static const _keyEventos = 'fav_eventos';

  Set<String> _noticias = {};
  Set<String> _eventos = {};
  bool _loaded = false;

  /// IDs de noticias favoritas (lectura).
  Set<String> get noticiaIds => Set.unmodifiable(_noticias);

  /// IDs de eventos favoritos (lectura).
  Set<String> get eventoIds => Set.unmodifiable(_eventos);

  /// Carga los favoritos desde disco. Se puede llamar varias veces sin problema.
  Future<void> ensureLoaded() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    _noticias = (prefs.getStringList(_keyNoticias) ?? []).toSet();
    _eventos = (prefs.getStringList(_keyEventos) ?? []).toSet();
    _loaded = true;
    notifyListeners();
  }

  // ---------- Queries ----------

  bool isFavorite(FavoriteType type, String id) {
    return _setFor(type).contains(id);
  }

  List<String> getFavorites(FavoriteType type) {
    return _setFor(type).toList();
  }

  // ---------- Mutations ----------

  Future<void> toggleFavorite(FavoriteType type, String id) async {
    final set = _setFor(type);
    if (set.contains(id)) {
      set.remove(id);
    } else {
      set.add(id);
    }
    notifyListeners();
    await _persist(type);
  }

  Future<void> addFavorite(FavoriteType type, String id) async {
    if (_setFor(type).add(id)) {
      notifyListeners();
      await _persist(type);
    }
  }

  Future<void> removeFavorite(FavoriteType type, String id) async {
    if (_setFor(type).remove(id)) {
      notifyListeners();
      await _persist(type);
    }
  }

  // ---------- Borrado total ----------

  /// Elimina todos los favoritos (para "Eliminar mis datos").
  Future<void> clearAll() async {
    _noticias.clear();
    _eventos.clear();
    _loaded = false;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyNoticias);
    await prefs.remove(_keyEventos);
  }

  // ---------- Internals ----------

  Set<String> _setFor(FavoriteType type) {
    return type == FavoriteType.noticia ? _noticias : _eventos;
  }

  String _keyFor(FavoriteType type) {
    return type == FavoriteType.noticia ? _keyNoticias : _keyEventos;
  }

  Future<void> _persist(FavoriteType type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyFor(type), _setFor(type).toList());
  }
}
