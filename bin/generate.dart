library json_translator;

import 'dart:io';

import 'package:json_translator/json_translator.dart';

Future<void> main(List<String> args) async {
  try {
    final Generator generator = Generator();
    final PubspecConfig config = PubspecConfig();
    stderr.writeln('INFO: Reading configs from pubspec.yaml.\n');
    await config.readConfigs();
    stderr.writeln('INFO: Starting translate.\n');
    await generator.generateAsync(config);
  } catch (e) {
    stderr.writeln('ERROR: Failed to translate json files.\n$e');
    exit(2);
  }
}
