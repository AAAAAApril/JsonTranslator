import 'dart:io';

import 'package:april_json_translator/src/language.dart';
import 'package:path/path.dart' as path;

import 'package:april_json_translator/src/configs.dart';
import 'package:april_json_translator/src/utils.dart';

///执行器
class Generator {
  const Generator();

  ///TODO 开始生成
  Future<void> generateAsync(PubspecConfig config) async {
    //读取源文件
    final File sourceFile = File(config.sourceFilePath);
    if (!(await sourceFile.exists())) {
      throw Exception('未找到源语言文件！');
    }
    //翻译之后的文件存储的文件夹
    final Directory parent = sourceFile.parent;
    //源语言 json
    final Map<dynamic, dynamic> sourceJson = await readJsonFromFile(sourceFile);
    if (sourceJson.isEmpty) {
      throw Exception('读取源语言文件失败，或者源语言文件没有需要翻译的内容。');
    }
    //目标语言文件
    final Map<Language, File> languageFile = <Language, File>{};
    //目标语言 json
    final Map<Language, Map<dynamic, dynamic>> languageJson =
        <Language, Map<dynamic, dynamic>>{};
    //读取以及创建目标文件
    for (var element in config.targetLanguages) {
      String fileName =
          '${config.resultFilePrefix}${element.languageCode}${config.resultFileSuffix}';
      File file = File(path.join(parent.path, fileName));
      //文件不存在
      if (!(await file.exists())) {
        //创建文件
        file = await file.create();
      }
      languageFile[element] = file;
      languageJson[element] = await readJsonFromFile(file);
    }
    //开始循环翻译所有需要翻译的内容
    for (var entry in sourceJson.entries) {
      dynamic key = entry.key;
      dynamic sourceValue = entry.value;
      //TODO 翻译
    }
  }
}
