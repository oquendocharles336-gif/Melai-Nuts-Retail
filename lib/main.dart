import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'app/app.dart';
import 'core/services/data_sync_service.dart';
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
  runApp(const MelaiNutsApp());
}