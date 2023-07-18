Description:
This tool is made to debug flutter_bloc[https://pub.dev/packages/flutter_bloc] states visually.

It uses BlocObserver to write all state changes in Json to a log file, this tool
listents to that file, parses the log, and prints it with easy to follow shapes and timelines.

It looks for logs that look like this:
[TIMESTAMP]: flutter: <jsonString>

Compatibility:
This is an internal tool that's built for use MacOS and Visual Studio Code. You are welcome to extend it to other platforms.

Set up:

1. Set this flag in VSCode project-specigic settings (project/.vscode/settings.json)
"dart.flutterRunLogFile": "/Users/john/project/project.log",

2. Add this flag to the DebugProfile Entitlements file:
example/macos/Runner/DebugProfile.entitlements
<key>com.apple.security.app-sandbox</key>
<false />

3. Set this constant at the top of main.dart
const kAbsoluteFilePath =
    "/Users/john/project/project.log";

Usage:
flutter run 
or flutter run -d macos
