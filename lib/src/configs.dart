import 'dart:io';

import 'package:yaml/yaml.dart';

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

///目标语言翻译结果生成的文件名前缀
const String filePrefixNodeName = 'file_prefix';

///目标语言翻译结果生成的文件名后缀
const String fileSuffixNodeName = 'file_suffix';

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

  ///读取配置
  Future<void> readConfigs() async {
    final File? pubspecFile = getPubspecFile();
    if (pubspecFile == null) {
      throw Exception('未找到 "pubspec.yaml" 文件');
    }

    /// pubspec.yaml  文件内容
    final YamlMap yamlContent = loadYaml(pubspecFile.readAsStringSync());

    ///配置节点
    final YamlMap? parentNode = yamlContent[configNodeName];
    if (parentNode == null) {
      throw Exception('未找到 "$configNodeName" 节点，该节点用于添加配置信息');
    }

    /// 找源语言编码
    final dynamic sourceLC = parentNode[sourceLanguageNodeName];
    if (sourceLC is String && sourceLC.isNotEmpty) {
      sourceLanguage = Language.fromString(sourceLC);
    }
    //没找到
    else {
      throw Exception(
        '未找到 "$sourceLanguageNodeName" 节点，或者节点值不合法，该节点用于设置源语言编码',
      );
    }

    /// 找目标语言编码列表
    final dynamic targetLCs = parentNode[targetLanguagesNodeName];
    if (targetLCs is String && targetLCs.isNotEmpty) {
      targetLanguages =
          targetLCs.split(',').map<Language>(Language.fromString).toList();
    }
    //没找到
    else {
      throw Exception(
        '未找到 "$targetLanguagesNodeName" 节点，或者节点值不合法，该节点用于设置目标语言编码列表',
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
        '未找到 "$sourceFilePathNodeName" 节点，或者节点值不合法，该节点用于设置源语言的文件路径',
      );
    }

    /// 找将要生成的目标文件的前缀
    final dynamic filePrefix = parentNode[filePrefixNodeName];
    if (filePrefix is String && filePrefix.isNotEmpty) {
      resultFilePrefix = filePrefix;
    }
    //没找到
    else {
      throw Exception(
        '未找到 "$filePrefixNodeName" 节点，或者节点值不合法，该节点用于设置目标语言翻译之后，生成的文件名前缀',
      );
    }

    /// 找将要生成的目标文件的后缀
    final dynamic fileSuffix = parentNode[fileSuffixNodeName];
    if (fileSuffix is String && fileSuffix.isNotEmpty) {
      resultFileSuffix = fileSuffix;
    }
    //没找到
    else {
      throw Exception(
        '未找到 "$fileSuffixNodeName" 节点，或者节点值不合法，该节点用于设置目标语言翻译之后，生成的文件名后缀',
      );
    }
  }
}
