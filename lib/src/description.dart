///文字的描述信息
class Description {
  const Description(this.value);

  ///描述具体数据
  final Object? value;

  ///是否需要翻译
  bool get needTranslate {
    try {
      Object? desc = value;
      if (desc is Map) {
        if ((desc['translate'] as bool) == false) {
          return false;
        }
      }
    } catch (_) {
      //ignore
    }
    return true;
  }
}
