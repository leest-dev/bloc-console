import 'dart:math';

import 'package:bloc_console/bloc/bloc.dart';
import 'package:bloc_console/repository/repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

const kAbsoluteFilePath =
    "/Users/mau/Development/leest-mobile/tmp/leest-app.log";
const kRefreshRate = Duration(milliseconds: 1000);
const kBufferSize = 100;

void main() {
  runApp(const BlocConsoleApp());
}

class BlocConsoleApp extends StatelessWidget {
  const BlocConsoleApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Leest Bloc Console',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
          useMaterial3: true,
        ),
        home: Scaffold(
            appBar: AppBar(
              title: const Text('Bloc Console'),
            ),
            body: ConsoleView(
                consoleAppBloc: ConsoleAppBloc(
                    repository: ConsoleAppRepository())
                  ..add(
                      ConsoleAppBlocInitialize(filePath: kAbsoluteFilePath)))));
  }
}

class ConsoleView extends StatelessWidget {
  const ConsoleView({required this.consoleAppBloc, Key? key}) : super(key: key);

  final ConsoleAppBloc consoleAppBloc;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: consoleAppBloc,
      child: Builder(builder: (context) {
        return Container(
          color: Theme.of(context).colorScheme.inverseSurface,
          padding: const EdgeInsets.only(top: 24.0),
          child: BlocBuilder<ConsoleAppBloc, ConsoleAppState>(
            buildWhen: (previous, current) {
              debugPrint(
                  'Build when called with ${current.status} lines and ${previous.status} lines equal? ${current == previous}');
              return current != previous;
            },
            builder: (context, state) {
              print('Building with ${state.lines.length} lines');
              if (state.status == ConsoleAppStateStatus.loading ||
                  state.status == ConsoleAppStateStatus.idle) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(
                        height: 24,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.75,
                        child: Text(
                          'Connecting to file: $kAbsoluteFilePath',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onInverseSurface),
                        ),
                      )
                    ],
                  ),
                );
              }

              return ListView.separated(
                  separatorBuilder: (BuildContext context, int index) {
                    return const Divider(
                      height: 16,
                      color: Colors.transparent,
                    );
                  },
                  itemCount: state.lines.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(state.lines[index].timestamp,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    color: HSLColor.fromColor(Theme.of(context)
                                            .colorScheme
                                            .inversePrimary)
                                        .withHue(
                                            Random().nextInt(360).toDouble())
                                        .toColor(),
                                  )),
                          const SizedBox(
                            width: 24,
                          ),
                          Expanded(
                            child: SelectableText(
                              state.lines[index].line,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onInverseSurface),
                            ),
                          ),
                        ],
                      ),
                    );
                  });
            },
          ),
        );
      }),
    );
  }
}
