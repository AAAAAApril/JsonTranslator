library april_json_translator;

import 'dart:io';

import 'package:april_json_translator/json_translator.dart';

Future<void> main(List<String> args) async {
  try {
    final PubspecConfig config = PubspecConfig();
    stdout.writeln('INFO: Reading configs from pubspec.yaml.');
    await config.readConfigs();
    final Generator generator = Generator();
    stdout.writeln('INFO: Starting translate.');
    await generator.generateAsync(config);
    stdout.writeln('INFO: Translate done.');
  } catch (e) {
    stderr.writeln('\nERROR: Failed to translate json files.\n$e');
    exit(2);
  }
}
