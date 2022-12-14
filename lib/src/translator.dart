import 'dart:convert';
import 'dart:io';

import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as parser;

///翻译工具
class Translator {
  Translator();

  final HttpClient client = HttpClient();

  void close() {
    client.close();
  }

  ///翻译
  Future<String> translate({
    //源语言编码
    required String sourceCode,
    //目标语言编码
    required String targetCode,
    //需要翻译的文字
    required String text,
  }) async {
    try {
      final HttpClientRequest request = await client.getUrl(
        Uri.parse(
          'https://translate.google.com/m?sl=$sourceCode&tl=$targetCode&q=$text',
        ),
      );
      final HttpClientResponse response = await request.close();
      if (response.statusCode != 200) {
        stderr.writeln(
          '\nERROR: Translate to language [$targetCode] failed with statusCode [${response.statusCode}] on [$text].\n',
        );
        return '';
      }
      final String body = await response.transform(const Utf8Decoder()).join();
      final dom.Element? element = (parser.parse(body)).querySelector(
        'div[class="result-container"]',
      );
      if (element == null) {
        stderr.writeln(
          '\nERROR: There is no div[class="result-container"] element in translate result html document.\n',
        );
        return '';
      }
      return element.text;
    } catch (_) {
      stderr.writeln(
        '\nERROR: Error when translate to language [$targetCode] on [$text] \n',
      );
      stderr.writeln(_.toString() + '\n');
      return '';
    }
  }
}
