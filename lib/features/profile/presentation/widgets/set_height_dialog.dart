import 'package:flutter/material.dart';
import 'package:horizontal_picker/horizontal_picker.dart';
import 'package:opennutritracker/generated/l10n.dart';

class SetHeightDialog extends StatelessWidget {
  static const _heightRangeCM = 100.0;
  static const _heightRangeFt = 10;

  final double userHeight;
  final bool usesImperialUnits;

  const SetHeightDialog(
      {super.key, required this.userHeight, required this.usesImperialUnits});

  @override
  Widget build(BuildContext context) {
    double selectedHeight = userHeight;
    // Ensure minValue doesn't go negative
    final minHeight = usesImperialUnits ? 1.0 : 50.0;
    final calculatedMin = usesImperialUnits
        ? selectedHeight - _heightRangeFt
        : selectedHeight - _heightRangeCM;
    final actualMin = calculatedMin > minHeight ? calculatedMin : minHeight;
    
    return AlertDialog(
      title: Text(S.of(context).selectHeightDialogLabel),
      content: Wrap(
        children: [
          Column(
            children: [
              HorizontalPicker(
                  height: 100,
                  backgroundColor: Colors.transparent,
                  minValue: actualMin,
                  maxValue: usesImperialUnits
                      ? selectedHeight + _heightRangeFt
                      : selectedHeight + _heightRangeCM,
                  divisions: 400,
                  suffix: usesImperialUnits
                      ? S.of(context).ftLabel
                      : S.of(context).cmLabel,
                  onChanged: (value) {
                    selectedHeight = value;
                  })
            ],
          )
        ],
      ),
      actions: <Widget>[
        TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(S.of(context).dialogCancelLabel)),
        TextButton(
            onPressed: () {
              // Validate selected height (prevent negative and unrealistic values)
              if (selectedHeight <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${S.of(context).selectHeightDialogLabel} must be greater than 0')),
                );
                return;
              }
              // Maximum reasonable height check (8 feet / 244 cm)
              final maxHeight = usesImperialUnits ? 8.0 : 244.0;
              if (selectedHeight > maxHeight) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${S.of(context).selectHeightDialogLabel} seems unrealistic')),
                );
                return;
              }
              Navigator.pop(context, selectedHeight);
            },
            child: Text(S.of(context).dialogOKLabel))
      ],
    );
  }
}
