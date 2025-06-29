import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../pages/AdmindashboardPage/admindashboard_page_widget.dart';
import '../../pages/Initial_Loading/initial_loading_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';

export 'package:go_router/go_router.dart';
export 'serialization_util.dart';

const kTransitionInfoKey = '__transition_info__';

GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

class AppStateNotifier extends ChangeNotifier {
  AppStateNotifier._();

  static AppStateNotifier? _instance;
  static AppStateNotifier get instance => _instance ??= AppStateNotifier._();

  bool showSplashImage = true;

  void stopShowingSplashImage() {
    showSplashImage = false;
    notifyListeners();
  }
}

GoRouter createRouter(AppStateNotifier appStateNotifier) => GoRouter(
  initialLocation: InitialLoadingPageWidget.routePath,
  debugLogDiagnostics: true,
  refreshListenable: appStateNotifier,
  navigatorKey: appNavigatorKey,
  errorBuilder: (context, state) => const SignINPageWidget(),

  redirect: (context, state) {
    final user = FirebaseAuth.instance.currentUser;
    final isLoggedIn = user != null;
    final isGoingToLogin = state.matchedLocation == SignINPageWidget.routePath;
    final isGoingToSignup = state.matchedLocation == SignupPageWidget.routePath;
    final isGoingToForgot = state.matchedLocation == ForgotpasswordPageWidget.routePath;
    final isGoingToInitialLoading = state.matchedLocation == InitialLoadingPageWidget.routePath;

    // Skip redirect if we're going to initial loading
    if (isGoingToInitialLoading) {
      return null;
    }

    // Allow unauthenticated users to access login/signup/forgot-password
    if (!isLoggedIn && !(isGoingToLogin || isGoingToSignup || isGoingToForgot)) {
      return SignINPageWidget.routePath;
    }

    // Prevent logged-in users from going to login
    if (isLoggedIn && isGoingToLogin) {
      return MainmenuPageWidget.routePath;
    }

    return null;
  },

  routes: [
    FFRoute(
      name: '_initialize',
      path: '/',
      builder: (context, _) => const InitialLoadingPageWidget(),
    ),
    FFRoute(
      name: InitialLoadingPageWidget.routeName,
      path: InitialLoadingPageWidget.routePath,
      builder: (context, params) => const InitialLoadingPageWidget(),
    ),
    FFRoute(
      name: LoadingPageWidget.routeName,
      path: LoadingPageWidget.routePath,
      builder: (context, params) => const LoadingPageWidget(),
    ),
    FFRoute(
      name: PredictionPageWidget.routeName,
      path: PredictionPageWidget.routePath,
      builder: (context, params) => const PredictionPageWidget(),
    ),
    FFRoute(
      name: HistoryPageWidget.routeName,
      path: HistoryPageWidget.routePath,
      builder: (context, params) => const HistoryPageWidget(),
    ),
    FFRoute(
      name: SettingsPageWidget.routeName,
      path: SettingsPageWidget.routePath,
      builder: (context, params) => const SettingsPageWidget(),
    ),
    FFRoute(
      name: AboutPageWidget.routeName,
      path: AboutPageWidget.routePath,
      builder: (context, params) => const AboutPageWidget(),
    ),
    FFRoute(
      name: AdmindashboardPageWidget.routeName,
      path: AdmindashboardPageWidget.routePath,
      builder: (context, params) => const AdmindashboardPageWidget(),
    ),
    FFRoute(
      name: SignupPageWidget.routeName,
      path: SignupPageWidget.routePath,
      builder: (context, params) => const SignupPageWidget(),
    ),
    FFRoute(
      name: MainmenuPageWidget.routeName,
      path: MainmenuPageWidget.routePath,
      builder: (context, params) => const MainmenuPageWidget(),
    ),
    FFRoute(
      name: EmergencypageWidget.routeName,
      path: EmergencypageWidget.routePath,
      builder: (context, params) => const EmergencypageWidget(),
    ),
    FFRoute(
      name: SignINPageWidget.routeName,
      path: SignINPageWidget.routePath,
      builder: (context, params) => const SignINPageWidget(),
    ),
    FFRoute(
      name: ForgotpasswordPageWidget.routeName,
      path: ForgotpasswordPageWidget.routePath,
      builder: (context, params) => const ForgotpasswordPageWidget(),
    ),
  ].map((r) => r.toRoute(appStateNotifier)).toList(),
);

// Rest of your existing extensions and classes...
extension NavParamExtensions on Map<String, String?> {
  Map<String, String> get withoutNulls => Map.fromEntries(
    entries
        .where((e) => e.value != null)
        .map((e) => MapEntry(e.key, e.value!)),
  );
}

extension NavigationExtensions on BuildContext {
  void safePop() {
    if (canPop()) {
      pop();
    } else {
      go('/');
    }
  }
}

extension _GoRouterStateExtensions on GoRouterState {
  Map<String, dynamic> get extraMap =>
      extra != null ? extra as Map<String, dynamic> : {};
  Map<String, dynamic> get allParams => <String, dynamic>{}
    ..addAll(pathParameters)
    ..addAll(uri.queryParameters)
    ..addAll(extraMap);
  TransitionInfo get transitionInfo => extraMap.containsKey(kTransitionInfoKey)
      ? extraMap[kTransitionInfoKey] as TransitionInfo
      : TransitionInfo.appDefault();
}

class FFParameters {
  FFParameters(this.state, [this.asyncParams = const {}]);

  final GoRouterState state;
  final Map<String, Future<dynamic> Function(String)> asyncParams;

  Map<String, dynamic> futureParamValues = {};

  bool get isEmpty =>
      state.allParams.isEmpty ||
          (state.allParams.length == 1 &&
              state.extraMap.containsKey(kTransitionInfoKey));
  bool isAsyncParam(MapEntry<String, dynamic> param) =>
      asyncParams.containsKey(param.key) && param.value is String;
  bool get hasFutures => state.allParams.entries.any(isAsyncParam);
  Future<bool> completeFutures() => Future.wait(
    state.allParams.entries.where(isAsyncParam).map(
          (param) async {
        final doc = await asyncParams[param.key]!(param.value)
            .onError((_, __) => null);
        if (doc != null) {
          futureParamValues[param.key] = doc;
          return true;
        }
        return false;
      },
    ),
  ).onError((_, __) => [false]).then((v) => v.every((e) => e));

  dynamic getParam<T>(
      String paramName,
      ParamType type, {
        bool isList = false,
      }) {
    if (futureParamValues.containsKey(paramName)) {
      return futureParamValues[paramName];
    }
    if (!state.allParams.containsKey(paramName)) {
      return null;
    }
    final param = state.allParams[paramName];
    if (param is! String) {
      return param;
    }
    return deserializeParam<T>(
      param,
      type,
      isList,
    );
  }
}

class FFRoute {
  const FFRoute({
    required this.name,
    required this.path,
    required this.builder,
    this.requireAuth = false,
    this.asyncParams = const {},
    this.routes = const [],
  });

  final String name;
  final String path;
  final bool requireAuth;
  final Map<String, Future<dynamic> Function(String)> asyncParams;
  final Widget Function(BuildContext, FFParameters) builder;
  final List<GoRoute> routes;

  GoRoute toRoute(AppStateNotifier appStateNotifier) => GoRoute(
    name: name,
    path: path,
    pageBuilder: (context, state) {
      fixStatusBarOniOS16AndBelow(context);
      final ffParams = FFParameters(state, asyncParams);
      final page = ffParams.hasFutures
          ? FutureBuilder(
        future: ffParams.completeFutures(),
        builder: (context, _) => builder(context, ffParams),
      )
          : builder(context, ffParams);
      final child = page;

      final transitionInfo = state.transitionInfo;
      return transitionInfo.hasTransition
          ? CustomTransitionPage(
        key: state.pageKey,
        child: child,
        transitionDuration: transitionInfo.duration,
        transitionsBuilder:
            (context, animation, secondaryAnimation, child) =>
            PageTransition(
              type: transitionInfo.transitionType,
              duration: transitionInfo.duration,
              reverseDuration: transitionInfo.duration,
              alignment: transitionInfo.alignment,
              child: child,
            ).buildTransitions(
              context,
              animation,
              secondaryAnimation,
              child,
            ),
      )
          : MaterialPage(key: state.pageKey, child: child);
    },
    routes: routes,
  );
}

class TransitionInfo {
  const TransitionInfo({
    required this.hasTransition,
    this.transitionType = PageTransitionType.fade,
    this.duration = const Duration(milliseconds: 300),
    this.alignment,
  });

  final bool hasTransition;
  final PageTransitionType transitionType;
  final Duration duration;
  final Alignment? alignment;

  static TransitionInfo appDefault() =>
      const TransitionInfo(hasTransition: false);
}

class RootPageContext {
  const RootPageContext(this.isRootPage, [this.errorRoute]);
  final bool isRootPage;
  final String? errorRoute;

  static bool isInactiveRootPage(BuildContext context) {
    final rootPageContext = context.read<RootPageContext?>();
    final isRootPage = rootPageContext?.isRootPage ?? false;
    final location = GoRouterState.of(context).uri.toString();
    return isRootPage &&
        location != '/' &&
        location != rootPageContext?.errorRoute;
  }

  static Widget wrap(Widget child, {String? errorRoute}) => Provider.value(
    value: RootPageContext(true, errorRoute),
    child: child,
  );
}

extension GoRouterLocationExtension on GoRouter {
  String getCurrentLocation() {
    final RouteMatch lastMatch = routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : routerDelegate.currentConfiguration;
    return matchList.uri.toString();
  }
}