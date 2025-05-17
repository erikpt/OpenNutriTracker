import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:opennutritracker/core/utils/bounds/validator.dart';
import 'package:opennutritracker/generated/l10n.dart';

class OnboardingSecondPageBody extends StatefulWidget {
  final Function(
    bool active,
    double? selectedHeight,
    double? selectedWeight,
    bool usesImperialUnits,
  ) setButtonContent;

  const OnboardingSecondPageBody({super.key, required this.setButtonContent});

  @override
  State<OnboardingSecondPageBody> createState() =>
      _OnboardingSecondPageBodyState();
}

class _OnboardingSecondPageBodyState extends State<OnboardingSecondPageBody> {
  final _heightFormKey = GlobalKey<FormState>();
  final _weightFormKey = GlobalKey<FormState>();
  final _heightFocusNode = FocusNode();
  final _weightFocusNode = FocusNode();
  final _isUnitSelected = [true, false];
  double? _parsedHeight;
  double? _parsedWeight;

  bool get _isImperialSelected => _isUnitSelected[1];

  @override
  void initState() {
    super.initState();
    _heightFocusNode.attach(context);
    _weightFocusNode.attach(context);
  }

  @override
  void dispose() {
    _heightFocusNode.dispose();
    _weightFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).heightLabel,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Text(
            S.of(context).onboardingHeightQuestionSubtitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16.0),
          Form(
            key: _heightFormKey,
            child: TextFormField(
              focusNode: _heightFocusNode,
              onChanged: (text) {
                if (_heightFormKey.currentState!.validate()) {
                  _parsedHeight = ValueValidator.parseHeightInCm(
                    double.tryParse(text.replaceAll(',', '.')),
                    isImperial: _isImperialSelected,
                  );
                  checkCorrectInput();
                } else {
                  _parsedHeight = null;
                  checkCorrectInput();
                }
              },
              onFieldSubmitted: (_) {
                FocusScope.of(context).requestFocus(_weightFocusNode);
              },
              validator: validateHeight,
              decoration: InputDecoration(
                labelText: _isImperialSelected ? 'ft' : 'cm',
                hintText: _isImperialSelected
                    ? S.of(context).onboardingHeightExampleHintFt
                    : S.of(context).onboardingHeightExampleHintCm,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                !_isImperialSelected
                    ? FilteringTextInputFormatter.digitsOnly
                    : FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+([.,]\d{0,1})?$'),
                      ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: ToggleButtons(
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              isSelected: _isUnitSelected,
              onPressed: (int index) {
                setState(() {
                  for (int i = 0; i < _isUnitSelected.length; i++) {
                    _isUnitSelected[i] = i == index;
                  }
                  _heightFormKey.currentState!.validate();
                  checkCorrectInput();
                });
              },
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(S.of(context).cmLabel),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(S.of(context).ftLabel),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32.0),
          Text(
            S.of(context).weightLabel,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Text(
            S.of(context).onboardingWeightQuestionSubtitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16.0),
          Form(
            key: _weightFormKey,
            child: TextFormField(
              focusNode: _weightFocusNode,
              onChanged: (text) {
                if (_weightFormKey.currentState!.validate()) {
                  _parsedWeight = ValueValidator.parseWeightInKg(
                    double.tryParse(text),
                    isImperial: _isImperialSelected,
                  );
                  checkCorrectInput();
                } else {
                  _parsedWeight = null;
                  checkCorrectInput();
                }
              },
              onFieldSubmitted: (_) {
                FocusScope.of(context).unfocus();
              },
              validator: validateWeight,
              decoration: InputDecoration(
                labelText: _isImperialSelected
                    ? S.of(context).lbsLabel
                    : S.of(context).kgLabel,
                hintText: _isImperialSelected
                    ? S.of(context).onboardingWeightExampleHintLbs
                    : S.of(context).onboardingWeightExampleHintKg,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: ToggleButtons(
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              isSelected: _isUnitSelected,
              onPressed: (int index) {
                setState(() {
                  for (int i = 0; i < _isUnitSelected.length; i++) {
                    _isUnitSelected[i] = i == index;
                  }
                  _weightFormKey.currentState!.validate();
                  checkCorrectInput();
                });
              },
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(S.of(context).kgLabel),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(S.of(context).lbsLabel),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String? validateHeight(String? value) {
    return ValueValidator.heightStringValidator(
      value,
      S.of(context).onboardingWrongHeightLabel,
      isImperial: _isImperialSelected,
    );
  }

  String? validateWeight(String? value) {
    return ValueValidator.weightStringValidator(
      value,
      S.of(context).onboardingWrongWeightLabel,
      isImperial: _isImperialSelected,
    );
  }

  void checkCorrectInput() {
    final isHeightValid = _heightFormKey.currentState?.validate() ?? false;
    final isWeightValid = _weightFormKey.currentState?.validate() ?? false;

    if (isHeightValid && isWeightValid && _parsedHeight != null && _parsedWeight != null) {
      widget.setButtonContent(true, _parsedHeight, _parsedWeight, _isImperialSelected);
    } else {
      widget.setButtonContent(false, null, null, _isImperialSelected);
    }
  }
}
