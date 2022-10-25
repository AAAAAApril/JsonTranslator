import 'dart:io';

import 'package:april_json_translator/src/translator.dart';
import 'package:path/path.dart' as path;

import 'package:april_json_translator/src/configs.dart';
import 'package:april_json_translator/src/utils.dart';

///执行器
class Generator {
  const Generator();

  /// 开始生成 （每翻译完成一个语言就写入文件）
  Future<void> generateAsync(PubspecConfig config) async {
    //读取源文件
    final File sourceFile = File(config.sourceFilePath);
    if (!(await sourceFile.exists())) {
      throw Exception('未找到源语言文件！');
    }
    //翻译之后文件存储的文件夹
    final Directory parent = sourceFile.parent;
    //源语言 json
    final Map<dynamic, dynamic> sourceJson = await readJsonFromFile(sourceFile);
    if (sourceJson.isEmpty) {
      throw Exception('读取源语言文件失败，或者源语言文件没有需要翻译的内容。');
    }

    ///开始循环所有的目标语言
    for (var language in config.targetLanguages) {
      //目标文件，和源文件放在同一个文件夹中
      File targetFile = File(path.join(
        parent.path,
        '${config.resultFilePrefix}${language.languageCode}${config.resultFileSuffix}',
      ));
      //文件不存在
      if (!(await targetFile.exists())) {
        //创建文件
        targetFile = await targetFile.create(recursive: true);
      }
      //目标文件现有的内容
      final Map<dynamic, dynamic> targetJson =
          await readJsonFromFile(targetFile);

      ///开始逐条翻译
      final Map<dynamic, dynamic> resultJson = await _translate(
        sourceLanguageCode: config.sourceLanguage.translateCode,
        targetLanguageCode: language.translateCode,
        sourceJson: sourceJson,
        targetJson: targetJson,
      );

      ///对比两个 json 是否相等
      bool changed = targetJson.length != resultJson.length;
      if (!changed) {
        //从后往前开始检查
        for (var entry in resultJson.entries.toList().reversed) {
          //旧 json 中，有任何一个 value ，和新 json 中的对应值不同，则表示发生了变化
          if (targetJson[entry.key] != entry.value) {
            changed = true;
            break;
          }
        }
      }

      //改变了
      if (changed) {
        ///将结果写入文件
        await targetFile.writeAsString(createFileContentByJson(resultJson));
        stderr.writeln(
          'INFO: Write result json into [${language.languageCode}] language file succeed.\n',
        );
      }
      //没变
      else {
        stderr.writeln(
          'INFO: There is no change of language file [${language.languageCode}].\n',
        );
      }
    }
  }

  ///开始循环翻译，完成之后返回完整的结果 json
  Future<Map<dynamic, dynamic>> _translate({
    //源语言编码
    required final String sourceLanguageCode,
    //目标语言编码
    required final String targetLanguageCode,
    //源语言 json
    required final Map<dynamic, dynamic> sourceJson,
    //目标语言 json
    required final Map<dynamic, dynamic> targetJson,
  }) async {
    ///最终结果
    final Map<dynamic, dynamic> resultJson = <dynamic, dynamic>{};

    ///翻译器
    Translator? translator;

    stderr.writeln(
      'INFO: Language [$targetLanguageCode] translate starting.\n',
    );

    ///循环翻译
    for (var entry in sourceJson.entries) {
      //源语言 key
      final dynamic sourceKey = entry.key;
      //源语言 value
      final dynamic sourceValue = entry.value;
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
          resultJson[sourceKey] = targetValue;
        }
        //其他情况需要翻译
        else {
          ///开始翻译
          String value = await (translator ??= Translator()).translate(
            sourceCode: sourceLanguageCode,
            targetCode: targetLanguageCode,
            text: sourceValue,
          );
          //赋值翻译结果
          if (value.isNotEmpty) {
            resultJson[sourceKey] = value;
          }
          //翻译结果为空，表示出错了
          else {
            //ignore 翻译出错时，不添加这个结果
            stderr.writeln(
              'ERROR (!!! IMPORTANT !!!): Translate to language [$targetLanguageCode] failed for [key:$sourceKey], this key will be remove from result json.\n',
            );
          }
        }
      }

      ///这个不需要翻译
      else {
        //如果目标文件中的这个值为 null
        if (targetValue == null) {
          //则将源文件中的对应值给目标文件
          resultJson[sourceKey] = sourceValue;
        }
        //不为 null
        else {
          resultJson[sourceKey] = targetValue;
        }
      }
    }

    stderr.writeln(
      'INFO: Language [$targetLanguageCode] translate completed.\n',
    );

    ///翻译完成之后，关闭翻译器
    translator?.close();

    return resultJson;
  }
}
