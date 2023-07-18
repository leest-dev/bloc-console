import 'dart:convert';
import 'dart:io';

import 'package:equatable/equatable.dart';

class ConsoleAppRepository {
  static ConsoleAppRepository? _instance;

  factory ConsoleAppRepository() {
    _instance ??= ConsoleAppRepository._internal();
    return _instance!;
  }

  ConsoleAppRepository._internal() {
    _instance = this;
  }

  Stream<LogLine> readLines(String absoluteFilePath) async* {
    final file = File(absoluteFilePath);

    final lines = file
        .openRead()
        .transform(utf8.decoder) // Decode bytes to UTF-8.
        .transform(const LineSplitter());
    await for (var line in lines) {
      yield parseLine(line);
    }
  }

  static LogLine parseLine(String line) {
    var logLine = line;
    var timestamp = '';
    if (line.contains('flutter:')) {
      timestamp = line.substring(1, line.indexOf(']'));
      logLine = line.substring(line.indexOf('flutter:'));
      if (logLine.contains('flutter:')) {
        logLine = logLine.replaceAll('flutter:', '');
      }

      return LogLine(
        line: logLine,
        timestamp: timestamp,
      );
    }
    return const LogLine.empty();
  }
}

class LogLine extends Equatable {
  final String line;
  final String timestamp;

  const LogLine.empty()
      : line = '',
        timestamp = '';

  const LogLine({required this.line, required this.timestamp});

  @override
  List<Object?> get props => [line, timestamp];
}
