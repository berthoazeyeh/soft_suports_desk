import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:path_provider/path_provider.dart';
import 'package:soft_support_decktop/api/cubit/synchronisation_cubit.dart';
import 'package:soft_support_decktop/api/cubit/user_cubit.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'theme/app_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'init_application.dart';
import 'ui/screens/home_screen.dart';
import 'package:hive/hive.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var appDir = HydratedStorage.webStorageDirectory;

  appDir = await getApplicationDocumentsDirectory();
  Hive.init(appDir.path);

  await Future.wait(
    [
      HydratedStorage.build(storageDirectory: appDir).then(
        (storage) => HydratedBloc.storage = storage,
      ),
    ],
    eagerError: true,
  );
  // HydratedBloc.storage = await HydratedStorage.build(
  //   storageDirectory: kIsWeb
  //       ? HydratedStorage.webStorageDirectory
  //       : await getApplicationDocumentsDirectory(),
  // );
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  final database = await InitApplication.initMyApplication();
  if (kDebugMode) {
    print(database.isOpen);
    print(database.path);
  }
  await initializeDateFormatting('fr_FR', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthCubit()),
        BlocProvider(create: (_) => SynchronisationCubit()),
      ],
      child: MaterialApp(
        title: 'Africasystems RFID Reader',
        theme: AppTheme.lightTheme,
        home: const HomeScreen(title: 'Africasystems RFID Reader'),
        builder: EasyLoading.init(),
      ),
    );
  }
}
