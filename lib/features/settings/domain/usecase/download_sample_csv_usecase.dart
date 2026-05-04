import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:opennutritracker/core/utils/csv_meal_importer.dart';

class DownloadSampleCsvUsecase {
  static const sampleFileName = 'opennutritracker-meals-sample.csv';

  /// Writes the bundled sample CSV to a user-chosen location. Returns true
  /// when the save was confirmed, false when the user cancelled.
  Future<bool> downloadSample() async {
    final csvString = CsvMealImporter.sampleCsv();
    final bytes = Uint8List.fromList(utf8.encode(csvString));

    final result = await FilePicker.saveFile(
      fileName: sampleFileName,
      type: FileType.custom,
      allowedExtensions: ['csv'],
      bytes: bytes,
    );

    return result != null && result.isNotEmpty;
  }
}
