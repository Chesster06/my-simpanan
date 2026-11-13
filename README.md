# MySimpanan

A disciplined savings goal tracker with scheduled monthly installments, Pay Early checklist, and smart reminders.

## Feature Highlights

- **Multi-Goal Savings Management**: Track and manage personal financial goals such as ASNB, emergency funds, and milestone savings targets.
- **Automated Monthly Commitment Calculation**: Calculates precise monthly commitments across chosen durations with penny-exact remainder distribution.
- **Installment Schedule with Pay Early Support**: View detailed monthly payment breakdown, mark individual installments in advance with instant progress updates, or settle the next pending commitment.
- **Offline Persistence**: Reliable local storage with persistent state across app restarts.
- **Smart Notification Reminders**: Configurable reminder lead times and daily alert times before scheduled due dates.
- **Clean Design System**: Purpose-built palette with rounded logo badge styling and clear status badges.

## Getting Started

### Prerequisites

- Flutter SDK (3.x or later)
- Compatible Android, iOS, macOS, Windows, or Linux development environment

### Installation & Execution

1. Clone or download the repository into your local workspace:
   ```bash
   git clone <repository-url>
   cd mysimpanan
   ```

2. Fetch project dependencies:
   ```bash
   flutter pub get
   ```

3. Analyze codebase for quality checks:
   ```bash
   flutter analyze
   ```

4. Run unit, widget, and end-to-end integration tests:
   ```bash
   flutter test
   ```

5. Launch the application on a connected device or simulator:
   ```bash
   flutter run
   ```

## Architecture & Project Structure

- `lib/models/`: Core domain models (`SavingsGoal`, `InstallmentItem`, `PaymentStatus`).
- `lib/providers/`: State management and business logic (`SavingsProvider`).
- `lib/repositories/`: Local data persistence interface and implementations (`SavingsRepository`).
- `lib/services/`: Pure computational logic (`InstallmentCalculator`, `NotificationService`).
- `lib/theme/`: Colors, typography, and theme definitions.
- `lib/screens/`: Feature screens (`DashboardScreen`, `CreateGoalScreen`, `GoalDetailScreen`, `SettingsScreen`).
- `lib/widgets/`: Reusable UI elements (`AppLogoBadge`, `SummaryHeaderCard`, `SavingsGoalCard`, `InstallmentRowItem`, `InstallmentStatusChip`).
- `test/`: Comprehensive unit, widget, and end-to-end test suites.
