import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/savings_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/app_logo_badge.dart';

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

  Future<void> _handleResetAllData(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Text(
          'Reset All Data?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: const Text(
          'This will permanently delete all your savings goals and installment history. This action cannot be undone.',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: const Text(
              'Reset',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await widget.provider.clearAllGoals();
      if (!mounted) return;
      ScaffoldMessenger.of(this.context).showSnackBar(
        const SnackBar(
          content: Text('All savings data has been reset'),
          backgroundColor: AppColors.textPrimary,
          behavior: SnackBarBehavior.floating,
        ),
      );
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
        title: const Text(
          'Settings',
          style: TextStyle(
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
                _buildSectionTitle('Reminder Preferences'),
                const SizedBox(height: 8),
                _buildCard([
                  SwitchListTile(
                    value: _remindersEnabled,
                    activeThumbColor: AppColors.primary,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    title: const Text(
                      'Enable Installment Reminders',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    subtitle: const Text(
                      'Receive notifications for upcoming monthly deadlines',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    onChanged: _setRemindersEnabled,
                  ),
                  const Divider(height: 1, color: AppColors.border),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    title: const Text(
                      'Reminder Lead Time',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    subtitle: const Text(
                      'How early before due date to alert',
                      style: TextStyle(
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
                    title: const Text(
                      'Daily Reminder Time',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    subtitle: const Text(
                      'Time of day notifications will fire',
                      style: TextStyle(
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
                _buildSectionTitle('Data Management'),
                const SizedBox(height: 8),
                _buildCard([
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.delete_outline,
                        color: AppColors.error,
                        size: 20,
                      ),
                    ),
                    title: const Text(
                      'Reset All Data',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.error,
                      ),
                    ),
                    subtitle: const Text(
                      'Delete all savings goals, installments, and logs',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    onTap: () => _handleResetAllData(context),
                  ),
                ]),
                const SizedBox(height: 24),
                _buildSectionTitle('About'),
                const SizedBox(height: 8),
                _buildCard([
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Center(
                          child: AppLogoBadge(size: AppLogoBadgeSize.medium),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'MySimpanan',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '1.0.0',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'A disciplined savings goal tracker with scheduled monthly installments, Pay Early checklist, and smart reminders.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
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
