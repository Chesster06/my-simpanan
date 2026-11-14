import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/savings_provider.dart';
import '../services/locale_service.dart';
import '../theme/app_colors.dart';
import 'about_screen.dart';

class SettingsScreen extends StatefulWidget {
  static const String keyRemindersEnabled = 'pref_reminders_enabled';
  static const String keyReminderLeadDays = 'pref_reminder_lead_days';
  static const String keyReminderHour = 'pref_reminder_time_hour';
  static const String keyReminderMinute = 'pref_reminder_time_minute';

  final SavingsProvider provider;

  const SettingsScreen({
    super.key,
    required this.provider,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _remindersEnabled = true;
  int _reminderLeadDays = 3;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 9, minute: 0);
  bool _isLoading = true;

  static final List<DropdownMenuItem<String>> _languageDropdownItems =
      LocaleService.allLanguages.map((lang) {
    return DropdownMenuItem<String>(
      value: lang.name,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            lang.name,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Language code: ${lang.code.toUpperCase()}',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }).toList();

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _remindersEnabled = prefs.getBool(SettingsScreen.keyRemindersEnabled) ?? true;
      _reminderLeadDays = prefs.getInt(SettingsScreen.keyReminderLeadDays) ?? 3;
      final hour = prefs.getInt(SettingsScreen.keyReminderHour) ?? 9;
      final minute = prefs.getInt(SettingsScreen.keyReminderMinute) ?? 0;
      _reminderTime = TimeOfDay(hour: hour, minute: minute);
      _isLoading = false;
    });
  }

  Future<void> _setRemindersEnabled(bool value) async {
    setState(() => _remindersEnabled = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(SettingsScreen.keyRemindersEnabled, value);
  }

  Future<void> _setReminderLeadDays(int value) async {
    setState(() => _reminderLeadDays = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(SettingsScreen.keyReminderLeadDays, value);
  }

  Future<void> _selectReminderTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _reminderTime = picked);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(SettingsScreen.keyReminderHour, picked.hour);
      await prefs.setInt(SettingsScreen.keyReminderMinute, picked.minute);
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          LocaleService.instance.tr('settings'),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: AppColors.border,
            height: 1.0,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            )
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              children: [
                _buildSectionTitle(LocaleService.instance.tr('choose_language')),
                const SizedBox(height: 8),
                _buildCard([
                  Theme(
                    data: Theme.of(context).copyWith(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      focusColor: Colors.transparent,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          key: const Key('settings_language_dropdown'),
                          isExpanded: true,
                          value: LocaleService.instance.currentLanguage.name,
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: AppColors.textSecondary,
                            size: 24,
                          ),
                          dropdownColor: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          menuMaxHeight: 360,
                          items: _languageDropdownItems,
                          selectedItemBuilder: (context) {
                            return LocaleService.allLanguages.map((lang) {
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    lang.name,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Language code: ${lang.code.toUpperCase()}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              );
                            }).toList();
                          },
                          onChanged: (selectedName) {
                            if (selectedName != null) {
                              final selectedOpt = LocaleService.allLanguages.firstWhere(
                                (l) => l.name == selectedName,
                                orElse: () => LocaleService.instance.currentLanguage,
                              );
                              setState(() {
                                LocaleService.instance.setLanguage(selectedOpt);
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ]),
                const SizedBox(height: 24),
                _buildSectionTitle(LocaleService.instance.tr('reminder_preferences')),
                const SizedBox(height: 8),
                _buildCard([
                  SwitchListTile(
                    value: _remindersEnabled,
                    activeThumbColor: AppColors.primary,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    title: Text(
                      LocaleService.instance.tr('enable_installment_reminders'),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      LocaleService.instance.tr('receive_notifications_deadline'),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    onChanged: _setRemindersEnabled,
                  ),
                  const Divider(height: 1, color: AppColors.border),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    title: Text(
                      LocaleService.instance.tr('reminder_lead_time'),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      LocaleService.instance.tr('how_early_to_alert'),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    trailing: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _reminderLeadDays,
                        icon: const Icon(Icons.arrow_drop_down, color: AppColors.textPrimary),
                        dropdownColor: AppColors.surface,
                        items: const [
                          DropdownMenuItem(value: 1, child: Text('1 day before')),
                          DropdownMenuItem(value: 3, child: Text('3 days before')),
                          DropdownMenuItem(value: 5, child: Text('5 days before')),
                          DropdownMenuItem(value: 7, child: Text('7 days before')),
                        ],
                        onChanged: _remindersEnabled
                            ? (val) {
                                if (val != null) _setReminderLeadDays(val);
                              }
                            : null,
                      ),
                    ),
                  ),
                  const Divider(height: 1, color: AppColors.border),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    title: Text(
                      LocaleService.instance.tr('daily_reminder_time'),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      LocaleService.instance.tr('time_notifications_fire'),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    trailing: InkWell(
                      onTap: _remindersEnabled ? () => _selectReminderTime(context) : null,
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _remindersEnabled
                              ? AppColors.primary.withValues(alpha: 0.08)
                              : AppColors.border.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: _remindersEnabled ? AppColors.primary : AppColors.border,
                            width: 1.0,
                          ),
                        ),
                        child: Text(
                          _formatTime(_reminderTime),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _remindersEnabled ? AppColors.primary : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ]),
                const SizedBox(height: 24),
                _buildSectionTitle(LocaleService.instance.tr('about')),
                const SizedBox(height: 8),
                _buildCard([
                  ListTile(
                    key: const Key('settings_about_card_button'),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    title: Text(
                      LocaleService.instance.tr('about'),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right_rounded,
                      size: 22,
                      color: AppColors.textSecondary,
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const AboutScreen(),
                        ),
                      );
                    },
                  ),
                ]),
              ],
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(
          color: AppColors.border,
          width: 1.0,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}
