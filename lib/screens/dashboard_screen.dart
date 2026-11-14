import 'package:flutter/material.dart';
import '../models/savings_goal.dart';
import '../providers/savings_provider.dart';
import '../services/locale_service.dart';
import '../theme/app_colors.dart';
import '../widgets/app_logo_badge.dart';
import '../widgets/minimalist_svg_illustrations.dart';
import '../widgets/notched_bottom_nav_bar.dart';
import '../widgets/savings_goal_card.dart';
import '../widgets/summary_header_card.dart';
import 'create_goal_screen.dart';
import 'goal_detail_screen.dart';
import 'notifications_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  final SavingsProvider provider;
  final VoidCallback? onNewGoal;
  final ValueChanged<SavingsGoal>? onGoalTap;
  final VoidCallback? onSettingsTap;

  const DashboardScreen({
    super.key,
    required this.provider,
    this.onNewGoal,
    this.onGoalTap,
    this.onSettingsTap,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentTabIndex = 0;

  void _handleNewGoal(BuildContext context) {
    if (widget.onNewGoal != null) {
      widget.onNewGoal!();
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CreateGoalScreen(provider: widget.provider),
        ),
      );
    }
  }

  void _handleGoalTap(BuildContext context, SavingsGoal goal) {
    if (widget.onGoalTap != null) {
      widget.onGoalTap!(goal);
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => GoalDetailScreen(
            goalId: goal.id,
            provider: widget.provider,
          ),
        ),
      );
    }
  }

  void _handleNotificationsTap(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NotificationsScreen(provider: widget.provider),
      ),
    );
  }

  void _handleSettingsTap(BuildContext context) {
    if (widget.onSettingsTap != null) {
      widget.onSettingsTap!();
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => SettingsScreen(provider: widget.provider),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.provider,
      builder: (context, _) {
        final goals = widget.provider.goals;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: _currentTabIndex == 1
              ? null
              : AppBar(
                  backgroundColor: AppColors.surface,
                  elevation: 0,
                  surfaceTintColor: Colors.transparent,
                  centerTitle: true,
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(1.0),
                    child: Container(
                      color: AppColors.border,
                      height: 1.0,
                    ),
                  ),
                  // KIRI: Butang Settings (bersih tanpa background)
                  leading: IconButton(
                    key: const Key('app_bar_settings_button'),
                    icon: const Icon(
                      Icons.settings_outlined,
                      color: AppColors.textPrimary,
                      size: 24,
                    ),
                    tooltip: 'Settings',
                    onPressed: () => _handleSettingsTap(context),
                  ),
                  // TENGAH: Badge logo kecil + nama MySimpanan
                  title: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const AppLogoBadge(size: AppLogoBadgeSize.small),
                      const SizedBox(width: 8),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'MySimpanan',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF5660E5),
                              letterSpacing: -0.3,
                            ),
                          ),
                          Text(
                            'SAVINGS TRACKER',
                            style: TextStyle(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary.withValues(alpha: 0.7),
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  actions: [
                    IconButton(
                      key: const Key('app_bar_notifications_button'),
                      icon: const Icon(Icons.notifications_none_outlined, color: AppColors.textPrimary),
                      tooltip: 'Reminders & Notifications',
                      onPressed: () => _handleNotificationsTap(context),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
          body: SafeArea(
            child: widget.provider.isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  )
                : IndexedStack(
                    index: _currentTabIndex,
                    children: [
                      _buildHomeView(context, goals),
                      _buildAnalyticsView(context),
                    ],
                  ),
          ),
          bottomNavigationBar: NotchedBottomNavBar(
            currentIndex: _currentTabIndex,
            onTap: (index) {
              setState(() {
                _currentTabIndex = index;
              });
            },
            onAddGoal: () => _handleNewGoal(context),
          ),
        );
      },
    );
  }

  Widget _buildHomeView(BuildContext context, List<SavingsGoal> goals) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        SummaryHeaderCard(
          totalSavings: widget.provider.totalSavings,
          dueThisMonth: widget.provider.monthlyCommitmentForCurrentMonth,
          pendingCount: widget.provider.pendingInstallmentsCount,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              LocaleService.instance.tr('savings_goals'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            if (goals.isNotEmpty)
              Text(
                '${goals.length} ${LocaleService.instance.tr('active')}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (goals.isEmpty)
          _buildEmptyState(context)
        else
          ...goals.map((goal) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SavingsGoalCard(
                goal: goal,
                onTap: () => _handleGoalTap(context, goal),
              ),
            );
          }),
        const SizedBox(height: 48),
      ],
    );
  }

  Widget _buildAnalyticsView(BuildContext context) {
    final goals = widget.provider.goals;
    final totalTarget = widget.provider.totalTarget;
    final totalSavings = widget.provider.totalSavings;
    final overallProgress = totalTarget > 0 ? (totalSavings / totalTarget).clamp(0.0, 1.0) : 0.0;

    // Calculate dynamic monthly commitments & averages
    double totalMonthlyRates = 0.0;
    int totalInstallmentsCount = 0;
    int paidInstallmentsCount = 0;
    int pendingInstallmentsCount = 0;

    for (final g in goals) {
      totalInstallmentsCount += g.installments.length;
      for (final inst in g.installments) {
        totalMonthlyRates += inst.amount;
        if (inst.status.name == 'pending') {
          pendingInstallmentsCount++;
        } else {
          paidInstallmentsCount++;
        }
      }
    }

    final avgMonthlyCommitment = totalInstallmentsCount > 0
        ? totalMonthlyRates / totalInstallmentsCount
        : 0.0;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 1. Overall Progress Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                LocaleService.instance.tr('overall_progress'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: overallProgress,
                  minHeight: 12,
                  backgroundColor: AppColors.border,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(overallProgress * 100).toStringAsFixed(1)}% ${LocaleService.instance.tr('achieved')}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    '${goals.length} ${LocaleService.instance.tr('total_goals')}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 2. Average Statistics Grid (Purata & Key Metrics - sama tinggi & seimbang)
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 34),
                        child: Text(
                          LocaleService.instance.tr('avg_monthly_commitment'),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                            height: 1.3,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        LocaleService.instance.formatCurrency(avgMonthlyCommitment),
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 34),
                        child: Text(
                          LocaleService.instance.tr('total_target_amount'),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                            height: 1.3,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        LocaleService.instance.formatCurrency(totalTarget),
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 4. Savings Health Analysis & Installment Breakdown
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                LocaleService.instance.tr('savings_analysis'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Color(0xFF10B981),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        LocaleService.instance.tr('paid_installments'),
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '$paidInstallmentsCount',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(height: 1, color: AppColors.border),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF59E0B),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        LocaleService.instance.tr('pending_installments'),
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '$pendingInstallmentsCount',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFF59E0B),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 5. Active Goal Targets Breakdown
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                LocaleService.instance.tr('active_goal_targets'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              if (goals.isEmpty)
                Text(
                  LocaleService.instance.tr('no_goals_breakdown'),
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                )
              else
                ...goals.map((g) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            g.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Text(
                          '${LocaleService.instance.formatCurrency(g.currentSavings)} / ${LocaleService.instance.formatCurrency(g.targetAmount)}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
          width: 1.0,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InteractiveBouncyScale(
            onTap: () => _handleNewGoal(context),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                'assets/images/savings_empty_state.png',
                key: const Key('empty_state_illustration'),
                width: 140,
                height: 140,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            LocaleService.instance.tr('no_savings_goals_yet'),
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            LocaleService.instance.tr('start_savings_journey'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
