part of binary_marshalling;

class _MemberInfo {
  final _ClassInfo classInfo;

  final _Converter converter;

  final String name;

  final String nativeName;

  final Symbol simpleName;

  _MemberInfo({this.classInfo, this.converter, this.name, this.nativeName, this.simpleName});

  String toString() {
    return "$classInfo $name";
  }
}
