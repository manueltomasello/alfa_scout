import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:getwidget/getwidget.dart';
import 'package:alfa_scout/presentation/blocs/theme/theme_cubit.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<ThemeCubit>().state;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final textColor = isDark ? Colors.white : Colors.black87;
    final boxColor = isDark ? Colors.grey.shade800 : Colors.white;

    return Scaffold(
      appBar: GFAppBar(
        title: const Text('Impostazioni'),
        centerTitle: true,
        backgroundColor: Color(0xFF9B111E),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const GFTypography(
              text: 'Tema App',
              type: GFTypographyType.typo1,
              icon: Icon(Icons.color_lens, color: Color(0xFF9B111E)),
              showDivider: true,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: boxColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<ThemeMode>(
                  isExpanded: true,
                  value: themeMode,
                  dropdownColor: boxColor,
                  style: TextStyle(color: textColor, fontSize: 16),
                  items: [
                    DropdownMenuItem(
                      value: ThemeMode.system,
                      child: Text('Sistema', style: TextStyle(color: textColor)),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.light,
                      child: Text('Chiaro', style: TextStyle(color: textColor)),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.dark,
                      child: Text('Scuro', style: TextStyle(color: textColor)),
                    ),
                  ],
                  onChanged: (mode) {
                    if (mode != null) {
                      context.read<ThemeCubit>().setTheme(mode);
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
