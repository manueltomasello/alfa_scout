import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alfa_scout/services/theme_service.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  final ThemeService _themeService;

  ThemeCubit(this._themeService) : super(ThemeMode.system);

  Future<void> loadTheme() async {
    final savedTheme = await _themeService.loadThemeMode();
    emit(savedTheme);
  }

  void setTheme(ThemeMode mode) {
    emit(mode);
    _themeService.saveThemeMode(mode);
  }

  void setLightTheme() {
    setTheme(ThemeMode.light);
  }

  void setDarkTheme() {
    setTheme(ThemeMode.dark);
  }

  void setSystemTheme() {
    setTheme(ThemeMode.system);
  }
}

