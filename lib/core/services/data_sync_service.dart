import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// DataSyncService handles local database caching and cloud database synchronization.
///
/// Under the hood, Cloud Firestore maintains an indexed local disk cache (SQLite / LevelDB)
/// on mobile devices. When offline or on low connectivity, all product, inventory,
/// and order reads/writes execute instantly against the local database, then automatically
/// synchronize with the cloud database once network connectivity is restored.
class DataSyncService {
  DataSyncService._();
  static final DataSyncService instance = DataSyncService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// Initializes local persistence & caching settings for high-performance offline access.
  Future<void> initializeLocalDatabase() async {
    if (_isInitialized) return;

    try {
      if (!kIsWeb) {
        _firestore.settings = const Settings(
          persistenceEnabled: true,
          cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
        );
      }
      _isInitialized = true;
      debugPrint('Local Database & Cloud Sync initialized successfully.');
    } catch (e) {
      debugPrint('Local Database initialization warning: $e');
    }
  }

  /// Forces a sync pass between local cache and cloud database.
  Future<void> syncPendingWrites() async {
    try {
      await _firestore.waitForPendingWrites();
      debugPrint('All local writes synchronized to Cloud Firestore.');
    } catch (e) {
      debugPrint('Pending writes sync error: $e');
    }
  }

  /// Disables network to simulate offline mode or save bandwidth.
  Future<void> enableOfflineMode() async {
    await _firestore.disableNetwork();
  }

  /// Re-enables network synchronization with Cloud Firestore.
  Future<void> enableOnlineSync() async {
    await _firestore.enableNetwork();
  }
}
