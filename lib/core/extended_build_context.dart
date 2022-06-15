import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

extension ExtendedBuildContext<T> on BuildContext {

  closeKeyboard() {
    var currentFocus = FocusScope.of(this);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }

  // ignore: avoid_shadowing_type_parameters
  T provide<T>() => Provider.of<T>(this);
  // ignore: avoid_shadowing_type_parameters
  T provideOnce<T>() => Provider.of<T>(this, listen: false);

  Future<T?> navigate(String routeName, {Object? arguments}) => Navigator.of(this).pushNamed(routeName, arguments: arguments);
  // ignore: avoid_shadowing_type_parameters
  Future<T?> navigateAndReplace<T extends Object?, TO extends Object?>(
    String routeName, {
    TO? result,
    Object? arguments,
  }) =>
      Navigator.of(this).pushReplacementNamed(
        routeName,
        result: result,
        arguments: arguments,
      );
  // ignore: avoid_shadowing_type_parameters
  Future<T?> navigateAndRemoveUntil<T extends Object?>(String newRouteName, {Object? arguments}) => Navigator.of(this).pushNamedAndRemoveUntil(
        newRouteName,
        (Route<dynamic> route) => false,
        arguments: arguments,
      );
  // ignore: avoid_shadowing_type_parameters
  void pop<T extends Object?>([T? result]) => Navigator.of(this).pop<T>(result);
}
