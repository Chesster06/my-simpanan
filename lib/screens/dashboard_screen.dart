import 'package:flutter/material.dart';
import '../models/savings_goal.dart';
import '../providers/savings_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/app_logo_badge.dart';
import '../widgets/savings_goal_card.dart';
import '../widgets/summary_header_card.dart';
import 'create_goal_screen.dart';
import 'goal_detail_screen.dart';
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
            titleSpacing: 16,
            title: Row(
              children: [
                const AppLogoBadge(size: AppLogoBadgeSize.small),
                const SizedBox(width: 12),
                const Text(
                  'MySimpanan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                key: const Key('app_bar_add_goal_button'),
                icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary, size: 24),
                tooltip: 'Add Goal',
                onPressed: () => _handleNewGoal(context),
              ),
              IconButton(
                icon: const Icon(Icons.notifications_none_outlined, color: AppColors.textPrimary),
                tooltip: 'Reminders',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Reminders active for monthly installments.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined, color: AppColors.textPrimary),
                tooltip: 'Settings',
                onPressed: () => _handleSettingsTap(context),
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
                : _currentTabIndex == 0
                    ? _buildHomeView(context, goals)
                    : _buildAnalyticsView(context),
          ),
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(
                top: BorderSide(
                  color: AppColors.border,
                  width: 1.0,
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              bottom: true,
              minimum: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: BottomNavigationBar(
                  currentIndex: _currentTabIndex,
                  onTap: (index) {
                    setState(() {
                      _currentTabIndex = index;
                    });
                  },
                  backgroundColor: AppColors.surface,
                  selectedItemColor: AppColors.primary,
                  unselectedItemColor: AppColors.neutral,
                  selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                  unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
                  elevation: 0,
                  type: BottomNavigationBarType.fixed,
                  items: const [
                    BottomNavigationBarItem(
                      icon: Padding(
                        padding: EdgeInsets.only(bottom: 4),
                        child: Icon(Icons.home_filled),
                      ),
                      label: 'Dashboard',
                    ),
                    BottomNavigationBarItem(
                      icon: Padding(
                        padding: EdgeInsets.only(bottom: 4),
                        child: Icon(Icons.pie_chart_outline_rounded),
                      ),
                      label: 'Overview',
                    ),
                  ],
                ),
              ),
            ),
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
            const Text(
              'Savings Goals',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            if (goals.isNotEmpty)
              Text(
                '${goals.length} active',
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

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
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
              const Text(
                'Overall Progress',
                style: TextStyle(
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
                    '${(overallProgress * 100).toStringAsFixed(1)}% Achieved',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    '${goals.length} Total Goals',
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
              const Text(
                'Active Goal Targets',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              if (goals.isEmpty)
                const Text(
                  'No goals created yet. Create a goal to see breakdown analytics.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
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
                          'RM ${g.currentSavings.toStringAsFixed(2)} / RM ${g.targetAmount.toStringAsFixed(2)}',
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
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
          width: 1.0,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.savings_outlined,
              size: 40,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Savings Goals Yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Start your savings journey by creating your first monthly commitment goal.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            key: const Key('empty_state_create_goal_button'),
            onPressed: () => _handleNewGoal(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            icon: const Icon(Icons.add, size: 18),
            label: const Text(
              'Create First Goal',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
