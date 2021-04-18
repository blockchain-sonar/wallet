export "src/tonclient_contract.dart";
export "src/tonclient_emulator.dart" // Default emulator implementation
    if (dart.library.io) "src/tonclient_io.dart" // dart:io implementation
    if (dart.library.html) "src/tonclient_js.dart"; // dart:html implementation
