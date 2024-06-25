import 'package:flutter/material.dart';
import 'TrainSync.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:training_sync/upload_manager.dart';
import 'package:training_sync/features/authentication/auth_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UploadManager())
      ],
      child: const TrainSync(),
    ),
  );
}
