import 'dart:io';

void main() async {
  final file = File('coverage/lcov.info');
  if (!await file.exists()) {
    print('Coverage file not found.');
    return;
  }

  final lines = await file.readAsLines();
  final Map<String, _FileCoverage> coverage = {};
  String? currentFile;

  for (final line in lines) {
    if (line.startsWith('SF:')) {
      currentFile = line
          .substring(3)
          .replaceAll('\\', '/'); // Standardize paths
      // Make path relative to lib if possible for readability
      if (currentFile.contains('/lib/')) {
        currentFile = 'lib/' + currentFile.split('/lib/').last;
      }
      coverage[currentFile] = _FileCoverage(currentFile);
    } else if (line.startsWith('DA:')) {
      if (currentFile != null) {
        final parts = line.substring(3).split(',');
        final hits = int.tryParse(parts[1]) ?? 0;
        coverage[currentFile]!.totalLines++;
        if (hits > 0) coverage[currentFile]!.coveredLines++;
      }
    }
  }

  print('Coverage Summary:');
  print('--------------------------------------------------');
  print(
    '${'File'.padRight(60)} | ${'Coverage'.padLeft(8)} | ${'Missed'.padLeft(6)}',
  );
  print('--------------------------------------------------');

  int totalLinesProject = 0;
  int coveredLinesProject = 0;
  final sortedFiles = coverage.keys.toList()..sort();

  for (final fileName in sortedFiles) {
    final cov = coverage[fileName]!;
    totalLinesProject += cov.totalLines;
    coveredLinesProject += cov.coveredLines;

    final percent = (cov.coveredLines / cov.totalLines * 100).toStringAsFixed(
      1,
    );
    final missed = cov.totalLines - cov.coveredLines;

    // Highlight low coverage
    final mark = double.parse(percent) < 50.0 ? '!' : ' ';

    print('$mark ${fileName.padRight(58)} | $percent% | $missed');
  }

  print('--------------------------------------------------');
  final totalPercent =
      totalLinesProject > 0
          ? (coveredLinesProject / totalLinesProject * 100).toStringAsFixed(1)
          : '0.0';
  print(
    'Total Project Coverage: $totalPercent% ($coveredLinesProject / $totalLinesProject lines)',
  );
}

class _FileCoverage {
  final String fileName;
  int totalLines = 0;
  int coveredLines = 0;
  _FileCoverage(this.fileName);
}
