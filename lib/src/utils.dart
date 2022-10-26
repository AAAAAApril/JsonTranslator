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
Future<Map<String, dynamic>> readJsonFromFile(File file) async {
  try {
    return Map<String, dynamic>.from(
        jsonDecode(await file.readAsString()) as Map);
  } catch (_) {
    return <String, dynamic>{};
  }
}

///根据 json 生成文件内容模板
String createFileContentByJson(Map<String, dynamic> json) {
  return mapTemp(json, offset: 0);
}

/// Map 类型的模板
String mapTemp(
  Map map, {
  int offset = 0,
}) {
  final String space = '  ' * offset;
  //当前循环到的下标
  final StringBuffer buffer = StringBuffer();
  buffer.write('{\n');
  int index = 0;
  for (var entry in map.entries) {
    index += 1;
    String end = '${(index == map.length) ? '' : ','}\n';
    dynamic value = entry.value;
    //字符串
    if (value is String) {
      if (value.contains('\n')) {
        value = value.replaceAll('\n', '\\n');
      }
      buffer.write('$space  "${entry.key}": "$value"$end');
    }
    //Map
    else if (value is Map) {
      String inner;
      if (value.isEmpty) {
        inner = '{}';
      } else {
        inner = '${mapTemp(value, offset: offset + 1)}';
      }
      buffer.write('$space  "${entry.key}": $inner$end');
    }
    //List
    else if (value is List) {
      String inner;
      if (value.isEmpty) {
        inner = '[]';
      } else {
        inner = '${listTemp(value, offset: offset + 1)}';
      }
      buffer.write('$space  "${entry.key}": $inner$end');
    }
    // other
    else {
      buffer.write('$space  "${entry.key}": $value$end');
    }
  }
  buffer.write('$space}');
  return buffer.toString();
}

/// List 类型的模板
String listTemp(
  List list, {
  int offset = 0,
}) {
  final String space = '  ' * offset;
  //当前循环到的下标
  final StringBuffer buffer = StringBuffer();
  buffer.write('[\n');
  int index = 0;
  for (var element in list) {
    index += 1;
    String end = '${(index == list.length) ? '' : ','}\n';
    //字符串
    if (element is String) {
      buffer.write('$space  "$element"$end');
    }
    // Map
    else if (element is Map) {
      buffer.write('$space  ${mapTemp(element, offset: offset + 1)}$end');
    }
    // List
    else if (element is List) {
      buffer.write('$space  ${listTemp(element, offset: offset + 1)}$end');
    }
    //other
    else {
      buffer.write('$space  $element$end');
    }
  }
  buffer.write('$space]');
  return buffer.toString();
}
