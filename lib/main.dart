import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'providers/auth_provider.dart';
import 'providers/player_provider.dart';
import 'providers/scoring_provider.dart';
import 'providers/recording_provider.dart';
import 'providers/catalog_provider.dart';

/// Entry point — wraps all providers around CadenceaApp.
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PlayerProvider()),
        ChangeNotifierProvider(create: (_) => ScoringProvider()),
        ChangeNotifierProvider(create: (_) => RecordingProvider()),
        ChangeNotifierProvider(create: (_) => CatalogProvider()..fetchSongs()),
      ],
      child: const CadenceaApp(),
    ),
  );
}
