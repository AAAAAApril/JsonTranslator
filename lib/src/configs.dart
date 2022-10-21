import 'dart:io';

import 'package:yaml/yaml.dart';

import 'utils.dart';

/// 配置在 pubspec.yaml 中的参数
class PubspecConfig {
  PubspecConfig();

  ///源语言的 语言编码
  late final String sourceLanguageCode;

  ///目标语言的 语言编码
  late final List<String> targetLanguageCodes;

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

    ///找源语言编码
    final dynamic sourceLC = parentNode[sourceLanguageCodeNodeName];
    //找到了
    if (sourceLC is String) {
      sourceLanguageCode = sourceLC;
    }
    //没找到
    else {
      throw Exception(
        '未找到 "$sourceLanguageCodeNodeName" 节点，或者节点值不合法，该节点用于设置源语言编码',
      );
    }

    ///TODO 找目标语言编码列表
    ///TODO 找将要生成的目标文件的前缀
    ///TODO 找将要生成的目标文件的后缀
  }
}

///配置参数根节点名
const String configNodeName = 'april_json_translator';

///源语言编码节点名
const String sourceLanguageCodeNodeName = 'source_language_code';

///目标语言编码节点名
const String targetLanguageCodesNodeName = 'target_language_codes';
