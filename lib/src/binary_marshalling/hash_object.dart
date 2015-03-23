part of binary_marshalling;

class _HashObject {
  final int base;

  final int offset;

  final TypeMirror typeMirror;

  int _hashCode;

  _HashObject({this.base, this.offset, this.typeMirror});

  int get hashCode {
    if (_hashCode == null) {
      _hashCode = 0;
      _hashCode ^= base & 0x3fffffff;
      _hashCode ^= offset & 0x3fffffff;
      _hashCode ^= typeMirror.hashCode & 0x3fffffff;
    }

    return _hashCode;
  }

  bool operator ==(other) {
    if (other is _HashObject) {
      if (offset == other.offset) {
        if (typeMirror == other.typeMirror) {
          if (base == other.base) {
            return true;
          }
        }
      }
    }

    return false;
  }
}
