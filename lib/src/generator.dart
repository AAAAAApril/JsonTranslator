import 'dart:io';

import 'package:april_json_translator/src/language.dart';
import 'package:april_json_translator/src/translator.dart';
import 'package:path/path.dart' as path;

import 'package:april_json_translator/src/configs.dart';
import 'package:april_json_translator/src/utils.dart';

///执行器
class Generator {
  const Generator();

  /// 开始生成
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
        file = await file.create(recursive: true);
      }
      languageFile[element] = file;
      languageJson[element] = await readJsonFromFile(file);
    }
    //翻译器
    final Translator translator = Translator();
    //开始循环翻译所有需要翻译的内容
    for (var sourceEntry in sourceJson.entries) {
      //源语言 key
      final dynamic sourceKey = sourceEntry.key;
      //源语言 value
      final dynamic sourceValue = sourceEntry.value;

      //目标语言
      for (var targetLanguage in List.of(languageJson.keys)) {
        //目标语言内容
        final Map<dynamic, dynamic> targetJson =
            Map<dynamic, dynamic>.of(languageJson[targetLanguage]!);
        //目标语言 value
        dynamic targetValue = targetJson[sourceKey];

        ///源语言 key 和 value 都为字符串，
        ///并且 key 不是某些特殊符号开始。
        ///这个可能需要翻译。
        if (sourceKey is String &&
            sourceValue is String &&
            !sourceKey.startsWith('_') &&
            !sourceKey.startsWith('@')) {
          //目标 value 不是 空字符串
          if (targetValue is String && targetValue.isNotEmpty) {
            //ignore 不需要翻译
          }
          //其他情况需要翻译
          else {
            ///开始翻译
            String value = await translator.translate(
              sourceCode: config.sourceLanguage.translateCode,
              targetCode: targetLanguage.translateCode,
              text: sourceValue,
            );
            //赋值翻译结果
            if (value.isNotEmpty) {
              targetJson[sourceKey] = value;
            }
            //翻译结果为空，表示出错了
            else {
              //ignore 翻译出错时，添加这个结果
            }
          }
        }

        ///这个不需要翻译
        else {
          //如果目标文件中的这个值为 null
          if (targetValue == null) {
            //则将源文件中的对应值给目标文件
            targetJson[sourceKey] = sourceValue;
          }
          //不为 null
          else {
            //ignore 不赋值，也不翻译。
          }
        }
        //重新赋值目标语言内容
        languageJson[targetLanguage] = targetJson;
      }
    }
    //翻译完成之后，关闭翻译器
    translator.close();
    stderr.writeln(
      'INFO: All text translate completed, start write into file.\n',
    );
    //循环写入 json 到文件
    for (var element in languageFile.entries) {
      final Language language = element.key;

      ///写入 json 到文件
      await writeText2File(
        language: language,
        targetFile: element.value,
        text: createFileContentByJson(languageJson[language]!),
      );
    }
  }
}
