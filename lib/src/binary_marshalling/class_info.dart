part of binary_marshalling;

class _ClassInfo {
  final Map<String, _MemberInfo> members;

  final ClassMirror classMirror;

  _ClassInfo({this.classMirror, this.members});

  String toString() {
    return MirrorSystem.getName(classMirror.simpleName);
  }
}
