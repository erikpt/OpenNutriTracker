import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:opennutritracker/core/domain/entity/intake_type_entity.dart';
import 'package:opennutritracker/core/utils/locator.dart';
import 'package:opennutritracker/features/add_meal/presentation/add_meal_type.dart';
import 'package:opennutritracker/features/scanner/domain/usecase/search_product_by_barcode_usecase.dart';
import 'package:opennutritracker/features/diary/presentation/bloc/calendar_day_bloc.dart';
import 'package:opennutritracker/features/diary/presentation/bloc/diary_bloc.dart';
import 'package:opennutritracker/features/home/domain/entity/shared_meal_payload.dart';
import 'package:opennutritracker/features/home/presentation/bloc/home_bloc.dart';
import 'package:opennutritracker/features/meal_detail/presentation/bloc/meal_detail_bloc.dart';
import 'package:opennutritracker/generated/l10n.dart';

class ImportMealScannerArguments {
  final IntakeTypeEntity intakeTypeEntity;
  final AddMealType addMealType;
  final DateTime day;

  ImportMealScannerArguments(this.intakeTypeEntity, this.addMealType, this.day);
}

class ImportMealScannerScreen extends StatefulWidget {
  const ImportMealScannerScreen({super.key});

  @override
  State<ImportMealScannerScreen> createState() =>
      _ImportMealScannerScreenState();
}

class _ImportMealScannerScreenState extends State<ImportMealScannerScreen> {
  late MealDetailBloc _mealDetailBloc;
  late SearchProductByBarcodeUseCase _searchProductByBarcodeUseCase;
  late IntakeTypeEntity _intakeTypeEntity;
  late AddMealType _addMealType;
  late DateTime _day;
  bool _isProcessing = false;

  @override
  void initState() {
    _mealDetailBloc = locator<MealDetailBloc>();
    _searchProductByBarcodeUseCase = locator<SearchProductByBarcodeUseCase>();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    final args = ModalRoute.of(context)?.settings.arguments
        as ImportMealScannerArguments;
    _intakeTypeEntity = args.intakeTypeEntity;
    _addMealType = args.addMealType;
    _day = args.day;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).importMealLabel),
        actions: [
          IconButton(
            icon: const Icon(Icons.keyboard_outlined),
            tooltip: S.of(context).pasteCodeLabel,
            onPressed: _showPasteCodeDialog,
          ),
        ],
      ),
      body: MobileScanner(
        controller: MobileScannerController(
          formats: const [BarcodeFormat.qrCode],
        ),
        onDetect: _onDetect,
      ),
    );
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null) return;
    await _processCode(raw);
  }

  Future<void> _showPasteCodeDialog() async {
    final controller = TextEditingController();
    final code = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(S.of(ctx).pasteCodeLabel),
        content: TextField(
          controller: controller,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: S.of(ctx).pasteCodeHint,
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(S.of(ctx).dialogCancelLabel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
            child: Text(S.of(ctx).importMealLabel),
          ),
        ],
      ),
    );
    if (code != null && code.isNotEmpty) {
      await _processCode(code);
    }
  }

  Future<void> _processCode(String raw) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final payload = SharedMealPayload.fromJsonString(raw);
      if (!mounted) return;
      final confirmed = await _showConfirmDialog(payload);
      if (confirmed == true && mounted) {
        await _importItems(payload);
        _refreshPages();
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(S.of(context).importMealSuccessLabel)),
          );
        }
      }
    } on SharedMealParseException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).importMealErrorLabel)),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<bool?> _showConfirmDialog(SharedMealPayload payload) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          S.of(ctx).importMealConfirmTitle(payload.totalCount),
        ),
        content: Text(
          S.of(ctx).importMealConfirmContent(_addMealType.getTypeName(ctx)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(S.of(ctx).dialogCancelLabel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(S.of(ctx).dialogOKLabel),
          ),
        ],
      ),
    );
  }

  Future<void> _importItems(SharedMealPayload payload) async {
    final meals = payload.toMealEntities();
    for (var i = 0; i < meals.length; i++) {
      _mealDetailBloc.addIntake(
        context,
        payload.items[i].unit,
        payload.items[i].amount.toString(),
        _intakeTypeEntity,
        meals[i],
        _day,
      );
    }

    final offResults = await Future.wait(payload.offRefs.map((ref) async {
      try {
        final meal = await _searchProductByBarcodeUseCase
            .searchProductByBarcode(ref.barcode);
        return (ref: ref, meal: meal);
      } catch (_) {
        return null;
      }
    }));

    if (!mounted) return;

    var skipped = 0;
    for (final r in offResults) {
      if (r != null) {
        _mealDetailBloc.addIntake(context, r.ref.unit, r.ref.amount.toString(),
            _intakeTypeEntity, r.meal, _day);
      } else {
        skipped++;
      }
    }

    if (skipped > 0 && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(S.of(context).importOffFetchFailedLabel(skipped))),
      );
    }
  }

  void _refreshPages() {
    locator<HomeBloc>().add(const LoadItemsEvent());
    locator<DiaryBloc>().add(const LoadDiaryYearEvent());
    locator<CalendarDayBloc>().add(RefreshCalendarDayEvent());
  }
}
