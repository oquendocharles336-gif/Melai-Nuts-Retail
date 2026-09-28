import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'app/app.dart';
import 'core/services/branch_controller.dart';
import 'core/services/connectivity_service.dart';
import 'core/services/customer_data_store.dart';
import 'core/services/data_sync_service.dart';
import 'core/services/supabase_service.dart';
import 'data/repositories/products_repository.dart';
import 'features/customer/cart_controller.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } on FirebaseException catch (e) {
    // On Android the native SDK may already have created [DEFAULT] from
    // google-services.json; that instance is fine to use. Anything else is a
    // real failure and must not be swallowed.
    if (e.code != 'duplicate-app') rethrow;
  }
  await DataSyncService.instance.initializeLocalDatabase();
  await SupabaseService.instance.initialize();
  // Catalog is public read data (see supabase/schema.sql policies) — load it
  // up front so it's ready the moment the storefront screens build, guest
  // browsing included. If this fails (e.g. offline), the screens themselves
  // retry and show their existing empty-state UI instead of crashing boot.
  unawaited(ProductsRepository.instance.loadCatalog());

  // Real connectivity detection: when the device comes back online after
  // being offline, re-fetch everything that could have changed while it
  // was gone — never assume the stale in-memory copy is still current.
  // This is the "when connectivity returns" resync the offline-support spec
  // asks for: products/stock, orders, customer profile/loyalty/notifications
  // (all four via CustomerDataStore.refresh — see its implementation), and
  // the cart's live pricing/stock.
  ConnectivityService.instance.onReconnect(() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      // Guest browsing: still worth refreshing the public catalog.
      await ProductsRepository.instance.loadCatalog(
        branchId: BranchController.instance.selectedBranch?.id,
      );
      return;
    }
    await Future.wait([
      ProductsRepository.instance.loadCatalog(
        branchId: BranchController.instance.selectedBranch?.id,
      ),
      CustomerDataStore.instance.refresh(),
      CartController.instance.refresh(),
    ]);
  });
  unawaited(ConnectivityService.instance.start());

  runApp(const MelaiNutsApp());
}