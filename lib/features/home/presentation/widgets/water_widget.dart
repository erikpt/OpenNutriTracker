import 'package:flutter/material.dart';
import 'package:opennutritracker/core/domain/entity/water_intake_entity.dart';
import 'package:opennutritracker/core/utils/locator.dart';
import 'package:opennutritracker/core/domain/usecase/add_water_usecase.dart';
import 'package:opennutritracker/features/home/presentation/bloc/home_bloc.dart';
import 'package:opennutritracker/generated/l10n.dart';

class WaterWidget extends StatelessWidget {
  final List<WaterIntakeEntity> waterIntakes;
  final bool usesImperialUnits;

  static const double _dailyGoalMl = 2000.0;
  static const double _mlToFlOz = 0.033814;

  const WaterWidget({
    super.key,
    required this.waterIntakes,
    required this.usesImperialUnits,
  });

  double get _totalMl =>
      waterIntakes.fold(0.0, (sum, e) => sum + e.amountMl);

  String _formatAmount(double ml) {
    if (usesImperialUnits) {
      return '${(ml * _mlToFlOz).toStringAsFixed(1)} fl oz';
    }
    return '${ml.toInt()} ml';
  }

  String _formatGoal() {
    if (usesImperialUnits) {
      return '${(_dailyGoalMl * _mlToFlOz).toStringAsFixed(1)} fl oz';
    }
    return '${_dailyGoalMl.toInt()} ml';
  }

  @override
  Widget build(BuildContext context) {
    final totalMl = _totalMl;
    final progress = (totalMl / _dailyGoalMl).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row
        Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Row(
            children: [
              Icon(Icons.water_drop_outlined,
                  size: 24,
                  color: Theme.of(context).colorScheme.onSurface),
              const SizedBox(width: 4.0),
              Text(
                S.of(context).waterLabel,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface),
              ),
              const Spacer(),
              Text(
                _formatAmount(totalMl),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7)),
              ),
            ],
          ),
        ),
        // Goal label + progress bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                S.of(context).waterDailyGoalLabel(_formatGoal()),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5)),
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 4,
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Horizontal scroll list
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: waterIntakes.length + 1, // +1 for add placeholder
            itemBuilder: (context, index) {
              final isFirst = index == 0;
              if (index == waterIntakes.length) {
                // Add placeholder card
                return _buildAddCard(context, isFirst);
              }
              return _buildWaterCard(context, waterIntakes[index], isFirst);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWaterCard(
      BuildContext context, WaterIntakeEntity entry, bool isFirst) {
    return Row(
      children: [
        SizedBox(width: isFirst ? 16 : 0),
        SizedBox(
          width: 120,
          height: 120,
          child: GestureDetector(
            onLongPress: () => _onDeletePressed(context, entry),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.water_drop_outlined,
                      color: Theme.of(context).colorScheme.primary,
                      size: 28,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatAmount(entry.amountMl),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddCard(BuildContext context, bool isFirst) {
    return Row(
      children: [
        SizedBox(width: isFirst ? 16 : 0),
        SizedBox(
          width: 120,
          height: 120,
          child: GestureDetector(
            onTap: () => _showAddWaterDialog(context),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.4),
                    size: 32,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    S.of(context).waterAddAmountLabel,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.4)),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  void _onDeletePressed(BuildContext context, WaterIntakeEntity entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(S.of(context).deleteTimeDialogTitle),
        content: Text(S.of(context).deleteTimeDialogContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(S.of(context).dialogCancelLabel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(S.of(context).waterDeleteLabel),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await locator<AddWaterUsecase>().deleteWaterIntake(entry.id);
      locator<HomeBloc>().add(const LoadItemsEvent());
    }
  }

  void _showAddWaterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => _AddWaterDialog(
        usesImperialUnits: usesImperialUnits,
        onAmountSelected: (amountMl) async {
          await locator<AddWaterUsecase>().addWaterIntake(amountMl);
          locator<HomeBloc>().add(const LoadItemsEvent());
        },
      ),
    );
  }
}

class _AddWaterDialog extends StatefulWidget {
  final bool usesImperialUnits;
  final Future<void> Function(double amountMl) onAmountSelected;

  const _AddWaterDialog({
    required this.usesImperialUnits,
    required this.onAmountSelected,
  });

  @override
  State<_AddWaterDialog> createState() => _AddWaterDialogState();
}

class _AddWaterDialogState extends State<_AddWaterDialog> {
  static const List<double> _presetAmountsMl = [
    150,
    250,
    330,
    500,
    750,
    1000,
  ];
  static const double _mlToFlOz = 0.033814;

  final TextEditingController _customController = TextEditingController();
  String? _customError;

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  String _formatPreset(double ml) {
    if (widget.usesImperialUnits) {
      return '${(ml * _mlToFlOz).toStringAsFixed(1)} fl oz';
    }
    return '${ml.toInt()} ml';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(S.of(context).waterAddAmountLabel),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _presetAmountsMl.map((ml) {
                return ActionChip(
                  label: Text(_formatPreset(ml)),
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await widget.onAmountSelected(ml);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _customController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: S.of(context).waterCustomAmountLabel,
                errorText: _customError,
                suffixText: widget.usesImperialUnits ? 'fl oz' : 'ml',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(S.of(context).dialogCancelLabel),
        ),
        TextButton(
          onPressed: () async {
            final text = _customController.text.trim();
            if (text.isEmpty) {
              setState(() => _customError = '');
              return;
            }
            final value = double.tryParse(text);
            if (value == null || value <= 0) {
              setState(() => _customError = '');
              return;
            }
            double amountMl = value;
            if (widget.usesImperialUnits) {
              amountMl = value / _mlToFlOz;
            }
            Navigator.of(context).pop();
            await widget.onAmountSelected(amountMl);
          },
          child: Text(S.of(context).addLabel),
        ),
      ],
    );
  }
}
