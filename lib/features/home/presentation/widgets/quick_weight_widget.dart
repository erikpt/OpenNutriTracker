import 'package:flutter/material.dart';
import 'package:opennutritracker/core/domain/usecase/add_user_usecase.dart';
import 'package:opennutritracker/core/domain/usecase/get_user_usecase.dart';
import 'package:opennutritracker/core/utils/locator.dart';
import 'package:opennutritracker/features/home/presentation/bloc/home_bloc.dart';
import 'package:opennutritracker/features/profile/presentation/widgets/set_weight_dialog.dart';
import 'package:opennutritracker/generated/l10n.dart';

/// #281: Quick weight update widget on the home/landing screen.
/// Displays current weight as a tappable chip; opens SetWeightDialog on tap.
class QuickWeightWidget extends StatefulWidget {
  final bool usesImperialUnits;

  const QuickWeightWidget({super.key, required this.usesImperialUnits});

  @override
  State<QuickWeightWidget> createState() => _QuickWeightWidgetState();
}

class _QuickWeightWidgetState extends State<QuickWeightWidget> {
  double? _weightKg;

  @override
  void initState() {
    super.initState();
    _loadWeight();
  }

  Future<void> _loadWeight() async {
    final user = await locator<GetUserUsecase>().getUserData();
    if (mounted) {
      setState(() => _weightKg = user.weightKG);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_weightKg == null) return const SizedBox.shrink();

    final displayWeight = widget.usesImperialUnits
        ? _weightKg! * 2.20462
        : _weightKg!;
    final unit = widget.usesImperialUnits
        ? S.of(context).lbsLabel
        : S.of(context).kgLabel;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          const Icon(Icons.monitor_weight_outlined, size: 18),
          const SizedBox(width: 8),
          Text(
            '${displayWeight.toStringAsFixed(1)} $unit',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 16),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            visualDensity: VisualDensity.compact,
            tooltip: S.of(context).editMealLabel,
            onPressed: () => _showWeightDialog(context),
          ),
        ],
      ),
    );
  }

  Future<void> _showWeightDialog(BuildContext context) async {
    final displayWeight = widget.usesImperialUnits
        ? _weightKg! * 2.20462
        : _weightKg!;

    final newWeight = await showDialog<double>(
      context: context,
      builder: (context) => SetWeightDialog(
        userWeight: displayWeight,
        usesImperialUnits: widget.usesImperialUnits,
      ),
    );

    if (newWeight == null || !context.mounted) return;

    final newWeightKg =
        widget.usesImperialUnits ? newWeight / 2.20462 : newWeight;

    final user = await locator<GetUserUsecase>().getUserData();
    await locator<AddUserUsecase>()
        .addUser(user..weightKG = newWeightKg);

    setState(() => _weightKg = newWeightKg);

    // Refresh home kcal goal (weight affects TDEE)
    locator<HomeBloc>().add(const LoadItemsEvent());
  }
}
