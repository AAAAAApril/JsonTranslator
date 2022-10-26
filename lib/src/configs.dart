import 'dart:io';

import 'package:yaml/yaml.dart';
import 'package:path/path.dart' as path;

import 'language.dart';
import 'utils.dart';

///配置参数根节点名
const String configNodeName = 'april_json_translator';

///源语言编码节点名
const String sourceLanguageNodeName = 'source_code';

///目标语言编码节点名
const String targetLanguagesNodeName = 'target_codes';

///源语言文件路径
const String sourceFilePathNodeName = 'source_file_path';

///保留以 @ 开头的 key
const String keepSpecialNodeName = 'keep_at_key';

/// 配置在 pubspec.yaml 中的参数
class PubspecConfig {
  PubspecConfig();

  ///源语言
  late final Language sourceLanguage;

  ///目标语言
  late final List<Language> targetLanguages;

  ///源语言文件的路径
  late final String sourceFilePath;

  ///生成的目标文件的前缀
  late final String resultFilePrefix;

  ///生成的目标文件的后缀
  late final String resultFileSuffix;

  ///是否保留描述
  late final bool keepDescription;

  ///读取配置
  Future<void> readConfigs() async {
    final File? pubspecFile = getPubspecFile();
    if (pubspecFile == null) {
      throw Exception('未找到 [pubspec.yaml] 文件');
    }

    /// pubspec.yaml  文件内容
    final YamlMap yamlContent = loadYaml(pubspecFile.readAsStringSync());

    ///配置节点
    final YamlMap? parentNode = yamlContent[configNodeName];
    if (parentNode == null) {
      throw Exception('未找到 [$configNodeName] 节点，该节点用于添加配置信息');
    }

    /// 找源语言编码
    final dynamic sourceLC = parentNode[sourceLanguageNodeName];
    if (sourceLC is String && sourceLC.isNotEmpty) {
      sourceLanguage = Language.fromString(sourceLC);
    }
    //没找到
    else {
      throw Exception(
        '未找到 [$sourceLanguageNodeName] 节点，或者节点值 [$sourceLC] 不合法，该节点用于设置源语言编码',
      );
    }

    /// 找目标语言编码列表
    final dynamic targetLCs = parentNode[targetLanguagesNodeName];
    if (targetLCs is String && targetLCs.isNotEmpty) {
      final List<String> codes = targetLCs.split(',');
      codes.removeWhere((element) => element.isEmpty);
      if (codes.isEmpty) {
        throw Exception(
          '节点 [$targetLanguagesNodeName] 值 [$targetLCs] 不合法，该节点用于设置目标语言编码列表',
        );
      }
      targetLanguages = codes.map<Language>(Language.fromString).toList();
    }
    //没找到
    else {
      throw Exception(
        '未找到 [$targetLanguagesNodeName] 节点，或者节点值 [$targetLCs] 不合法，该节点用于设置目标语言编码列表',
      );
    }

    /// 找源语言文件路径
    final dynamic sourceFile = parentNode[sourceFilePathNodeName];
    if (sourceFile is String && sourceFile.isNotEmpty) {
      sourceFilePath = sourceFile;
    }
    //没找到
    else {
      throw Exception(
        '未找到 [$sourceFilePathNodeName] 节点，或者节点值 [$sourceFile] 不合法，该节点用于设置源语言的文件路径',
      );
    }

    /// 生成的目标文件的前后缀
    final String fileName = path.basename(sourceFilePath);
    //以 源语言编码进行分割
    if (fileName.contains(sourceLanguage.languageCode)) {
      //得到文件名 前缀、后缀
      final List<String> fixList = fileName.split(sourceLanguage.languageCode);
      resultFilePrefix = fixList.first;
      resultFileSuffix = fixList.last;
    }
    //源语言和源文件不同名
    else {
      throw Exception(
        '[$sourceFilePathNodeName] value [$sourceFilePath] is not contains'
        ' [$sourceLanguageNodeName] value [${sourceLanguage.languageCode}]',
      );
    }

    /// 找是否需要保留描述 key
    try {
      final dynamic keepDesc = parentNode[keepSpecialNodeName];
      keepDescription = keepDesc.toString() == 'true';
    } catch (_) {
      keepDescription = false;
    }
  }
}
