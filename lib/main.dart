import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'screens/login_page.dart';
import 'screens/shell.dart';
import 'state/app_state.dart';
import 'state/scope.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es');
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  final store = AppState();
  await store.load();
  runApp(NexoApp(store: store));
}

class NexoApp extends StatelessWidget {
  const NexoApp({super.key, required this.store});

  final AppState store;

  @override
  Widget build(BuildContext context) {
    return AppStateScope(
      store: store,
      child: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          return MaterialApp(
            title: 'Lumi',
            debugShowCheckedModeBanner: false,
            theme: buildNexoTheme(),
            home: store.loggedIn ? const AppShell() : const LoginPage(),
          );
        },
      ),
    );
  }
}
