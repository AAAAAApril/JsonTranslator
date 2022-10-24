///语言
class Language {
  const Language({
    required this.languageCode,
    required this.translateCode,
  });

  factory Language.fromString(String value) {
    final String languageCode;
    final String translateCode;
    if (value.contains(':')) {
      final List<String> codes = value.split(':');
      languageCode = codes.first;
      translateCode = codes.last;
    } else {
      languageCode = value;
      translateCode = languageCode;
    }
    return Language(
      languageCode: languageCode,
      translateCode: translateCode,
    );
  }

  ///语言的编码（用于在生成文件时，填充到文件名中段的字符串，这个值不要求一定是真正的语言编码，它更主要的目的其实是[生成文件名]）
  final String languageCode;

  ///翻译时传递的编码
  ///
  ///Tips： 谷歌翻译需要传递的目标语言编码和 [languageCode] 可能会不一致，
  ///       并且：[languageCode] 会用于生成文件名，而使用者可能并不需要用一个真正的语言编码来命名文件。
  ///目前已知：
  ///   希伯来语 语言编码为 he，谷歌翻译时需要传递的值却是 iw；
  ///   中文简体 zh，需要传递的值是 zh-CN。
  final String translateCode;
}
