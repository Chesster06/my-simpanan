import 'package:flutter/material.dart';
import '../models/savings_goal.dart';
import '../providers/savings_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/app_logo_badge.dart';
import '../widgets/savings_goal_card.dart';
import '../widgets/summary_header_card.dart';
import 'create_goal_screen.dart';
import 'goal_detail_screen.dart';

class DashboardScreen extends StatelessWidget {
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

  void _handleNewGoal(BuildContext context) {
    if (onNewGoal != null) {
      onNewGoal!();
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CreateGoalScreen(provider: provider),
        ),
      );
    }
  }

  void _handleGoalTap(BuildContext context, SavingsGoal goal) {
    if (onGoalTap != null) {
      onGoalTap!(goal);
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => GoalDetailScreen(
            goalId: goal.id,
            provider: provider,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: provider,
      builder: (context, _) {
        final goals = provider.goals;

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
                icon: const Icon(Icons.settings_outlined, color: AppColors.textPrimary),
                tooltip: 'Settings',
                onPressed: onSettingsTap,
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: provider.isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    SummaryHeaderCard(
                      totalSavings: provider.totalSavings,
                      dueThisMonth: provider.monthlyCommitmentForCurrentMonth,
                      pendingCount: provider.pendingInstallmentsCount,
                    ),
                    const SizedBox(height: 24),
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
                  ],
                ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _handleNewGoal(context),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            icon: const Icon(Icons.add, size: 20),
            label: const Text(
              '+ New Goal',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      },
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
