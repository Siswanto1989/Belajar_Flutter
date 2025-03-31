import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';

import '../../data/datasources/local_data_source.dart';
import '../../data/models/personnel_model.dart';
import '../../data/models/report_model.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/personnel_repository_impl.dart';
import '../../data/repositories/report_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/personnel_repository.dart';
import '../../domain/repositories/report_repository.dart';
import '../../domain/usecases/auth_usecases.dart';
import '../../domain/usecases/personnel_usecases.dart';
import '../../domain/usecases/report_usecases.dart';
import '../../presentation/bloc/auth/auth_bloc.dart';
import '../../presentation/bloc/personnel/personnel_bloc.dart';
import '../../presentation/bloc/report/report_bloc.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Data sources
  getIt.registerLazySingleton<LocalDataSource>(
    () => LocalDataSourceImpl(
      usersBox: Hive.box<UserModel>('users'),
      personnelBox: Hive.box<PersonnelModel>('personnel'),
      reportsBox: Hive.box<ReportModel>('reports'),
      settingsBox: Hive.box('settings'),
    ),
  );

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(localDataSource: getIt<LocalDataSource>()),
  );
  
  getIt.registerLazySingleton<PersonnelRepository>(
    () => PersonnelRepositoryImpl(localDataSource: getIt<LocalDataSource>()),
  );
  
  getIt.registerLazySingleton<ReportRepository>(
    () => ReportRepositoryImpl(localDataSource: getIt<LocalDataSource>()),
  );

  // Use cases
  getIt.registerLazySingleton(
    () => AuthUseCases(
      loginUser: LoginUser(getIt<AuthRepository>()),
      logoutUser: LogoutUser(getIt<AuthRepository>()),
      checkAuthentication: CheckAuthentication(getIt<AuthRepository>()),
      verifyAdminPin: VerifyAdminPin(getIt<AuthRepository>()),
    ),
  );
  
  getIt.registerLazySingleton(
    () => PersonnelUseCases(
      getAllPersonnel: GetAllPersonnel(getIt<PersonnelRepository>()),
      getPersonnelByGroup: GetPersonnelByGroup(getIt<PersonnelRepository>()),
      updatePersonnel: UpdatePersonnel(getIt<PersonnelRepository>()),
      addPersonnel: AddPersonnel(getIt<PersonnelRepository>()),
      removePersonnel: RemovePersonnel(getIt<PersonnelRepository>()),
      movePersonnel: MovePersonnel(getIt<PersonnelRepository>()),
    ),
  );
  
  getIt.registerLazySingleton(
    () => ReportUseCases(
      getAllReports: GetAllReports(getIt<ReportRepository>()),
      getReportById: GetReportById(getIt<ReportRepository>()),
      saveReport: SaveReport(getIt<ReportRepository>()),
      deleteReport: DeleteReport(getIt<ReportRepository>()),
      shareReportAsImage: ShareReportAsImage(getIt<ReportRepository>()),
      saveReportAsImage: SaveReportAsImage(getIt<ReportRepository>()),
    ),
  );

  // BLoCs
  getIt.registerFactory(
    () => AuthBloc(authUseCases: getIt<AuthUseCases>()),
  );
  
  getIt.registerFactory(
    () => PersonnelBloc(personnelUseCases: getIt<PersonnelUseCases>()),
  );
  
  getIt.registerFactory(
    () => ReportBloc(reportUseCases: getIt<ReportUseCases>()),
  );
}
