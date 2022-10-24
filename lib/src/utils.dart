import 'dart:convert';
import 'dart:io';
import 'package:april_json_translator/src/language.dart';
import 'package:path/path.dart' as path;

///项目跟路径
String getRootDirectoryPath() => Directory.current.path;

///获取配置文件
File? getPubspecFile() {
  var rootDirPath = getRootDirectoryPath();
  var pubspecFilePath = path.join(rootDirPath, 'pubspec.yaml');
  var pubspecFile = File(pubspecFilePath);
  return pubspecFile.existsSync() ? pubspecFile : null;
}

///从文件中读取 json
Future<Map<dynamic, dynamic>> readJsonFromFile(File file) async {
  try {
    return jsonDecode(await file.readAsString()) as Map<dynamic, dynamic>;
  } catch (_) {
    return const <dynamic, dynamic>{};
  }
}

///将文字写入到目标文件
Future<void> writeText2File({
  //目标语言
  required Language language,
  //目标文件
  required File targetFile,
  //目标文字
  required String text,
}) async {
  stderr.writeln(
    'INFO: Writing result json into [${language.languageCode}] language file.\n',
  );
  await targetFile.writeAsString(text);
}

///根据 json 生成文件内容模板
String createFileContentByJson(Map<dynamic, dynamic> json) {
  //当前循环到的下标
  final StringBuffer buffer = StringBuffer();
  buffer.write('{\n');
  int index = 0;
  for (var entry in json.entries) {
    index += 1;
    buffer.write(
      '  "${entry.key}": "${entry.value}"${(index == json.length) ? '' : ','}\n',
    );
  }
  buffer.write('}');
  return buffer.toString();
}
