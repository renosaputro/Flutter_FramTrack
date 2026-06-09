import 'package:get_it/get_it.dart';
import '../core/services/auth_service.dart';
import '../core/services/firestore_service.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  getIt.registerLazySingleton<AuthService>(() => AuthService());
  getIt.registerLazySingleton<FirestoreService>(() => FirestoreService());
}
