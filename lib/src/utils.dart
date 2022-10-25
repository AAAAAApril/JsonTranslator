import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;

///获取配置文件
File? getPubspecFile() {
  //项目跟路径
  var rootDirPath = Directory.current.path;
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

///根据 json 生成文件内容模板
String createFileContentByJson(Map<dynamic, dynamic> json) {
  //当前循环到的下标
  final StringBuffer buffer = StringBuffer();
  buffer.write('{\n');
  int index = 0;
  for (var entry in json.entries) {
    dynamic value = entry.value;
    if (value is String) {
      if (value.contains('\n')) {
        value = value.replaceAll('\n', '\\n');
      }
    }
    index += 1;
    buffer.write(
      '  "${entry.key}": "$value"${(index == json.length) ? '' : ','}\n',
    );
  }
  buffer.write('}');
  return buffer.toString();
}
