/// Simulated OCR extraction result passed between OCR flow screens.
///
/// There is no real OCR engine here — [OcrScanResult.simulatedSample]
/// returns realistic canned data (matching the prototype's sample batch
/// intake slip) so the Capture → Preview → Processing → Verify → Success
/// flow can be demoed end-to-end without a camera or backend.
class OcrScanResult {
  String productName;
  String matchedSku;
  String batchNumber;
  int quantity;
  DateTime manufactureDate;
  DateTime expirationDate;
  String receivingBranch;
  String receivingStaff;
  double confidence; // 0-1

  OcrScanResult({
    required this.productName,
    required this.matchedSku,
    required this.batchNumber,
    required this.quantity,
    required this.manufactureDate,
    required this.expirationDate,
    required this.receivingBranch,
    required this.receivingStaff,
    required this.confidence,
  });

  /// The default "good scan" sample, matching the prototype's Santa Cruz
  /// intake manifest example.
  factory OcrScanResult.simulatedSample() => OcrScanResult(
        productName: 'Garlic Peanuts (250g Standup Pouch)',
        matchedSku: 'MN-GP-250',
        batchNumber: '#MN-GP-045-SC',
        quantity: 180,
        manufactureDate: DateTime(2026, 8, 20),
        expirationDate: DateTime(2026, 11, 20),
        receivingBranch: 'Santa Cruz Flagship',
        receivingStaff: 'Paolo Reyes (Staff #8841)',
        confidence: 0.964,
      );

  /// A blank template used when someone chooses "Enter Information
  /// Manually" after a failed scan.
  factory OcrScanResult.blank() => OcrScanResult(
        productName: '',
        matchedSku: '',
        batchNumber: '',
        quantity: 0,
        manufactureDate: DateTime.now(),
        expirationDate: DateTime.now().add(const Duration(days: 90)),
        receivingBranch: 'Santa Cruz Flagship',
        receivingStaff: '',
        confidence: 0,
      );
}
