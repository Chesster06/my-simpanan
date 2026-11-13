import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../models/savings_goal.dart';
import '../providers/savings_provider.dart';
import '../services/installment_calculator.dart';
import '../theme/app_colors.dart';

class CreateGoalScreen extends StatefulWidget {
  final SavingsProvider provider;

  const CreateGoalScreen({
    super.key,
    required this.provider,
  });

  @override
  State<CreateGoalScreen> createState() => _CreateGoalScreenState();
}

class _CreateGoalScreenState extends State<CreateGoalScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _targetAmountController = TextEditingController();
  final _currentSavingsController = TextEditingController();

  DateTime _startDate = DateTime.now();
  late DateTime _targetDate;
  int _dueDay = 25;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _startDate = DateTime(now.year, now.month, now.day);
    // Default target date to 6 months in the future on due day
    _targetDate = DateTime(now.year, now.month + 6, _dueDay);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetAmountController.dispose();
    _currentSavingsController.dispose();
    super.dispose();
  }

  double get _targetAmount {
    return double.tryParse(_targetAmountController.text.trim()) ?? 0.0;
  }

  double get _currentSavings {
    return double.tryParse(_currentSavingsController.text.trim()) ?? 0.0;
  }

  int get _monthDifference {
    int diff = (_targetDate.year - _startDate.year) * 12 +
        (_targetDate.month - _startDate.month) +
        1;
    return diff < 1 ? 1 : diff;
  }

  double get _monthlyCommitment {
    final remaining = _targetAmount - _currentSavings;
    if (remaining <= 0 || _monthDifference <= 0) return 0.0;
    return remaining / _monthDifference;
  }

  Future<void> _selectTargetDate() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year, now.month, now.day);
    final lastDate = DateTime(now.year + 50, 12, 31);

    final initialDate = _targetDate.isBefore(firstDate) ? firstDate : _targetDate;

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
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
      setState(() {
        _targetDate = picked;
      });
    }
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final id = const Uuid().v4();
    final name = _nameController.text.trim();
    final targetAmount = _targetAmount;
    final currentSavings = _currentSavings;

    final schedule = InstallmentCalculator.generateSchedule(
      targetAmount: targetAmount,
      currentSavings: currentSavings,
      startDate: _startDate,
      targetDate: _targetDate,
      dueDay: _dueDay,
    );

    final newGoal = SavingsGoal(
      id: id,
      name: name,
      targetAmount: targetAmount,
      currentSavings: currentSavings,
      startDate: _startDate,
      targetDate: _targetDate,
      dueDay: _dueDay,
      installments: schedule,
    );

    widget.provider.addGoal(newGoal);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Goal created successfully'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'ms_MY',
      symbol: 'RM ',
      decimalDigits: 2,
    );
    final monthYearFormatter = DateFormat('MMM yyyy');
    final fullDateFormatter = DateFormat('dd MMM yyyy');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
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
        title: const Text(
          'New Savings Goal',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Goal Name Field
              _buildFieldLabel('Goal Name', isRequired: true),
              const SizedBox(height: 6),
              TextFormField(
                key: const Key('goal_name_field'),
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  hintText: 'e.g. ASNB Bumiputera, Emergency Fund',
                  hintStyle: const TextStyle(
                    color: AppColors.neutral,
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a goal name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),

              // Target Amount (RM)
              _buildFieldLabel('Target Amount (RM)', isRequired: true),
              const SizedBox(height: 6),
              TextFormField(
                key: const Key('target_amount_field'),
                controller: _targetAmountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  prefixText: 'RM ',
                  prefixStyle: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  hintText: '0.00',
                  hintStyle: const TextStyle(
                    color: AppColors.neutral,
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a valid target amount';
                  }
                  final parsed = double.tryParse(value.trim());
                  if (parsed == null || parsed <= 0) {
                    return 'Target amount must be greater than 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),

              // Current Savings (RM, optional)
              _buildFieldLabel('Current Initial Savings (RM)', isRequired: false),
              const SizedBox(height: 6),
              TextFormField(
                key: const Key('current_savings_field'),
                controller: _currentSavingsController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  prefixText: 'RM ',
                  prefixStyle: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  hintText: '0.00 (Optional)',
                  hintStyle: const TextStyle(
                    color: AppColors.neutral,
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    final parsed = double.tryParse(value.trim());
                    if (parsed == null || parsed < 0) {
                      return 'Current savings cannot be negative';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),

              // Target Date Selection
              _buildFieldLabel('Target Date', isRequired: true),
              const SizedBox(height: 6),
              InkWell(
                key: const Key('target_date_picker_tile'),
                onTap: _selectTargetDate,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        fullDateFormatter.format(_targetDate),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Icon(
                        Icons.calendar_month_outlined,
                        size: 20,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Monthly Due Day Selection
              _buildFieldLabel('Monthly Payment Due Day (1 to 28)', isRequired: true),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Selected Due Day',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          'Day $_dueDay of every month',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      key: const Key('due_day_slider'),
                      value: _dueDay.toDouble(),
                      min: 1,
                      max: 28,
                      divisions: 27,
                      activeColor: AppColors.primary,
                      inactiveColor: AppColors.border,
                      label: 'Day $_dueDay',
                      onChanged: (val) {
                        setState(() {
                          _dueDay = val.round();
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Live Calculation Banner
              _buildLivePreviewCard(currencyFormatter, monthYearFormatter),

              const SizedBox(height: 24),

              // Save Goal Action Button
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  key: const Key('save_goal_button'),
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Text(
                    'Save Goal',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label, {required bool isRequired}) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        if (isRequired)
          const Text(
            ' *',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.error,
            ),
          ),
      ],
    );
  }

  Widget _buildLivePreviewCard(
    NumberFormat currencyFormatter,
    DateFormat monthYearFormatter,
  ) {
    final commitment = _monthlyCommitment;
    final months = _monthDifference;
    final finalInstallment = monthYearFormatter.format(_targetDate);

    return Container(
      key: const Key('live_calculation_preview'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_graph_outlined,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              const Text(
                'Commitment Schedule Preview',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Duration:',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '$months ${months == 1 ? "month" : "months"}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Estimated Monthly Commitment:',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '${currencyFormatter.format(commitment)} / month',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Final Installment:',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                finalInstallment,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
