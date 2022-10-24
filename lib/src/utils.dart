import 'dart:convert';
import 'dart:io';
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
    return <dynamic, dynamic>{};
  }
}
