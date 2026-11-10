class MockFailureController {
  final Duration latency;
  bool simulateError = false;

  MockFailureController({this.latency = const Duration(milliseconds: 800)});
}
