import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:quran_a_day/data/bookmarks/bookmark_repository.dart';
import 'package:quran_a_day/data/notifications/notification_payload.dart';
import 'package:quran_a_day/data/notifications/notification_service.dart';

class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    log('onChange(${bloc.runtimeType}, $change)');
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    log('onError(${bloc.runtimeType}, $error, $stackTrace)');
    super.onError(bloc, error, stackTrace);
  }
}

Future<void> bootstrap(FutureOr<Widget> Function() builder) async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
  };

  Bloc.observer = const AppBlocObserver();

  await Hive.initFlutter(); // uses path_provider under the hood
  await BookmarkRepository.init();

  // // Notifications — init here so launch payload is available
  // await NotificationService.instance.init(
  //   onTap: (payload) {
  //     // Handle navigation from notification tap
  //     // We'll wire this to a GlobalKey<NavigatorState> in Step 6
  //     final parsed = NotificationPayload.fromPayloadString(payload);
  //     if (parsed != null) {
  //       debugPrint('Tapped notification for page ${parsed.pageNumber}');
  //       // navigatorKey.currentState?.push(...) — Step 6
  //     }
  //   },
  // );

  // Add cross-flavor configuration here

  runApp(await builder());
}
