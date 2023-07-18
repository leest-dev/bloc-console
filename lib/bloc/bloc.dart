import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_console/main.dart';
import 'package:bloc_console/repository/repository.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

class ConsoleAppBloc extends Bloc<ConsoleAppEvent, ConsoleAppState> {
  final ConsoleAppRepository repository;
  static ConsoleAppBloc? _instance;

  factory ConsoleAppBloc({required ConsoleAppRepository repository}) {
    _instance ??= ConsoleAppBloc._internal(repository: repository);
    return _instance!;
  }

  ConsoleAppBloc._internal({required this.repository})
      : super(ConsoleAppState()) {
    on<ConsoleAppBlocInitialize>((event, emit) {
      emit(state.copyWith(status: ConsoleAppStateStatus.loading));
      add(ConsoleAppOpenFileEvent(filePath: event.filePath));
    });

    on<ConsoleAppOpenFileEvent>((event, emit) async {
      var lines = <LogLine>[];
      await for (LogLine line in repository.readLines(event.filePath)) {
        lines = [line, ...lines];
      }
      lines = lines
          .where((element) =>
              element.line.isNotEmpty && !element.line.contains('➜'))
          .toList();
      add(ConsoleAppUpdateLines(lines: lines.take(kBufferSize).toList()));
      Future.delayed(kRefreshRate, () {
        add(ConsoleAppOpenFileEvent(filePath: event.filePath));
      });
    });

    on<ConsoleAppUpdateLines>((event, emit) {
      emit(state.copyWith(
          lines: event.lines, status: ConsoleAppStateStatus.loaded));
    });
  }

  @override
  Future<void> close() {
    _instance = null;

    return super.close();
  }
}

@immutable
abstract class ConsoleAppEvent {}

class ConsoleAppOpenFileEvent extends ConsoleAppEvent {
  final String filePath;

  ConsoleAppOpenFileEvent({required this.filePath});
}

class ConsoleAppBlocInitialize extends ConsoleAppEvent {
  final String filePath;

  ConsoleAppBlocInitialize({required this.filePath});
}

class ConsoleAppUpdateLines extends ConsoleAppEvent {
  final List<LogLine> lines;

  ConsoleAppUpdateLines({required this.lines});
}

enum ConsoleAppStateStatus { idle, loading, loaded, error }

@immutable
class ConsoleAppState extends Equatable {
  factory ConsoleAppState(
      {ConsoleAppStateStatus status = ConsoleAppStateStatus.idle}) {
    return ConsoleAppState._internal(status: status);
  }

  ConsoleAppState._internal(
      {required this.status, this.lines = const <LogLine>[]}) {
    _instance ??= this;
  }

  final ConsoleAppStateStatus status;
  static ConsoleAppState? _instance;
  final List<LogLine> lines;

  ConsoleAppState copyWith(
      {ConsoleAppStateStatus? status, List<LogLine>? lines}) {
    return ConsoleAppState._internal(
        status: status ?? this.status, lines: lines ?? this.lines);
  }

  @override
  List<Object> get props => [lines, status];

  @override
  bool? get stringify => true;
}
