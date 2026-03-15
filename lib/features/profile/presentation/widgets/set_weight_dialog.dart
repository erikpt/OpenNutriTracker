import 'package:flutter/material.dart';
import 'package:horizontal_picker/horizontal_picker.dart';
import 'package:opennutritracker/generated/l10n.dart';

class SetWeightDialog extends StatefulWidget {
  static const weightRangeKg = 50.0;
  static const weightRangeLbs = 100.0;

  final double userWeight;
  final bool usesImperialUnits;

  const SetWeightDialog({
    super.key,
    required this.userWeight,
    required this.usesImperialUnits,
  });

  @override
  State<SetWeightDialog> createState() => _SetWeightDialogState();
}

class _SetWeightDialogState extends State<SetWeightDialog> {
  late double selectedWeight;

  @override
  void initState() {
    super.initState();
    selectedWeight = widget.userWeight;
  }

  @override
  Widget build(BuildContext context) {
    final minValue = widget.usesImperialUnits
        ? widget.userWeight - SetWeightDialog.weightRangeLbs
        : widget.userWeight - SetWeightDialog.weightRangeKg;

    final maxValue = widget.usesImperialUnits
        ? widget.userWeight + SetWeightDialog.weightRangeLbs
        : widget.userWeight + SetWeightDialog.weightRangeKg;

    // Enforce minimum weight (#216, #253): 10kg or 20lbs
    final minWeight = widget.usesImperialUnits ? 20.0 : 10.0;

    return AlertDialog(
      title: Text(S.of(context).selectWeightDialogLabel),
      content: Wrap(
        children: [
          Column(
            children: [
              HorizontalPicker(
                height: 100,
                backgroundColor: Colors.transparent,
                minValue: minValue < minWeight ? minWeight : minValue, // enforce minimum weight (#216, #253)
                maxValue: maxValue,
                initialPosition: InitialPosition.center,
                divisions: 1000, // Supports decimal values (#244)
                suffix: widget.usesImperialUnits
                    ? S.of(context).lbsLabel
                    : S.of(context).kgLabel,
                onChanged: (value) {
                  setState(() {
                    selectedWeight = value < 0 ? 0 : value; // 👈 no negative values
                  });
                },
              ),
            ],
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(S.of(context).dialogCancelLabel),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, selectedWeight);
          },
          child: Text(S.of(context).dialogOKLabel),
        ),
      ],
    );
  }
}
