import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../domain/catalog_models.dart';

/// Local SQLite cache. Schema bumps via [version] + [onUpgrade].
class CatalogDatabase {
  CatalogDatabase(this._db);

  final Database _db;

  static const seedAsset = 'assets/data/catalog_v1.json';
  static const _seedMetaKey = 'catalog_seed_version';
  static const _seedVersion = 'v3';
  static const schemaVersion = 3;

  static Future<CatalogDatabase> open() async {
    final db = await openDatabase(
      join(await getDatabasesPath(), 'jd_catalog.db'),
      version: schemaVersion,
      onCreate: (db, _) async {
        await _createTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 3) {
          await _createTables(db);
          await db.delete('meta', where: 'key = ?', whereArgs: [_seedMetaKey]);
        }
      },
    );
    return CatalogDatabase(db);
  }

  static Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS catalog_blob (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        json TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS meta (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
  }

  Future<void> ensureSeeded() async {
    final row = await _db.query(
      'meta',
      where: 'key = ?',
      whereArgs: [_seedMetaKey],
    );
    if (row.isNotEmpty && row.first['value'] == _seedVersion) return;
    await replaceFromSeedAsset();
  }

  Future<Map<String, dynamic>> readRoot() async {
    final rows = await _db.query('catalog_blob', where: 'id = 1', limit: 1);
    if (rows.isEmpty) {
      final raw = await rootBundle.loadString(seedAsset);
      return jsonDecode(raw) as Map<String, dynamic>;
    }
    return jsonDecode(rows.first['json']! as String) as Map<String, dynamic>;
  }

  HomeCatalog parseHome(Map<String, dynamic> root) {
    final products = (root['products'] as List)
        .map((e) => CatalogProduct.fromJson(e as Map<String, dynamic>))
        .toList();
    final challengesRaw = root['challenges'] as List? ?? const [];
    return HomeCatalog(
      member: CatalogMember.fromJson(root['member'] as Map<String, dynamic>),
      banners: (root['banners'] as List)
          .map((e) => CatalogBanner.fromJson(e as Map<String, dynamic>))
          .toList(),
      sections: (root['sections'] as List)
          .map((e) => CatalogSection.fromJson(e as Map<String, dynamic>))
          .toList(),
      productsById: {for (final p in products) p.id: p},
      shops: (root['shops'] as List)
          .map((e) => CatalogShop.fromJson(e as Map<String, dynamic>))
          .toList(),
      challenges: challengesRaw
          .map((e) => CatalogChallenge.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<HomeCatalog> loadHome() async => parseHome(await readRoot());

  Future<CatalogProduct?> productById(String id) async {
    final home = await loadHome();
    return home.productsById[id];
  }

  Future<List<CatalogChallenge>> loadChallenges() async {
    final home = await loadHome();
    return home.challenges;
  }

  Future<void> replaceFromSeedAsset() async {
    final raw = await rootBundle.loadString(seedAsset);
    final existing = await _db.query('catalog_blob', where: 'id = 1', limit: 1);
    if (existing.isEmpty) {
      await _db.insert('catalog_blob', {'id': 1, 'json': raw});
    } else {
      await _db.update('catalog_blob', {'json': raw}, where: 'id = 1');
    }
    await _db.insert(
      'meta',
      {'key': _seedMetaKey, 'value': _seedVersion},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> close() => _db.close();
}
