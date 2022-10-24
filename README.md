<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->

## Getting started

Run `flutter pub global activate april_json_translator` in project Terminal for activate this tool.  

## Usage

1. Add this in your project pubspec.yaml with top level.  

```yaml
april_json_translator:
  source_code: 'en'
  target_codes: 'zh'
  source_file_path: 'lib/l10n/intl_en.arb'
  file_prefix: 'intl_'
  file_suffix: '.arb'
```

2. Run `flutter pub global run april_json_translator:generate` in project Terminal for translate your json file with this tool.  

---

In the above example, `en` and `zh` are both the code of the language to be translated and the mid-segment name of the file.  
You can set like `source_code: 'he:iw'` when language code is not the same as your mid-segment name of file.  
Before the `:` is the mid-segment name of file, after is the code of the language to be translated.  
If you need to translate into multiple languages, you can set like this `target_codes: 'zh:zh-CN,ja,ko'` just separate the language codes with `,`
