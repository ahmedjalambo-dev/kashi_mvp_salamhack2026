import 'package:flutter/material.dart';

/// Global route observer used to auto-refresh screens when the user
/// returns to them via Navigator.pop.
///
/// Wired into [MaterialApp.navigatorObservers] in `app.dart`. Screens that
/// need to re-fetch data on resurface mix in [RouteAware] (via the
/// `AutoRefreshRouteAware` mixin) and call their cubit's refresh method
/// from `didPopNext`.
final RouteObserver<PageRoute<dynamic>> appRouteObserver =
    RouteObserver<PageRoute<dynamic>>();

/// Mixin for [State] classes that want to auto-refresh whenever the user
/// returns to the screen. Subclasses override [onResurface] (and may also
/// override [onFirstAppearance]).
mixin AutoRefreshRouteAware<T extends StatefulWidget> on State<T>
    implements RouteAware {
  ModalRoute<dynamic>? _route;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute && route != _route) {
      if (_route != null) appRouteObserver.unsubscribe(this);
      _route = route;
      appRouteObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    super.dispose();
  }

  /// Called when this route is shown again after a pushed route is popped.
  void onResurface() {}

  @override
  void didPush() {}

  @override
  void didPushNext() {}

  @override
  void didPop() {}

  @override
  void didPopNext() => onResurface();
}
