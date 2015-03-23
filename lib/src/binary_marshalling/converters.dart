part of binary_marshalling;

class _DynamicConverter extends _Converter<dynamic> {
  dynamic convert(BinaryData data, Map converted) {
    return data.value;
  }
}

class _GenericConverter<T> extends _Converter<T> {
  T convert(BinaryData data, Map converted) {
    var value = data.value;
    if (value is T) {
      return value;
    }

    error(data.type, T);
    return null;
  }
}

class _ListConverter extends _Converter<List> {
  final _Converter elementConverter;

  final NullTerminated nullTerminated;

  _ListConverter(this.elementConverter, {this.nullTerminated});

  List convert(BinaryData data, Map converted) {
    var type = data.type;
    if (type is ArrayType) {
      var length = type.length;
      var result = [];
      result.length = length;
      var index = 0;
      for (; index < length; index++) {
        var element = data[index];
        var value = elementConverter.convert(element, converted);
        if (nullTerminated == null) {
          result[index] = value;
        } else {
          if (element.isNullPtr || value == null || value == 0) {
            if (nullTerminated.includeNull) {
              result[index] = value;
            }

            break;
          } else {
            result[index] = value;
          }
        }
      }

      var rest = length - index;
      if (rest > 0) {
        var value;
        var elementType = type.type;
        if (elementType is IntType) {
          value = 0;
        } else if (elementType is FloatingPointType) {
          value = 0.0;
        } else if (elementType is BoolType) {
          value = false;
        }

        if (value != null) {
          for (; index < length; index++) {
            result[index] = value;
          }
        }
      }

      return result;
    } else if (type is PointerType) {
      var result = [];
      var index = 0;
      while (true) {
        var element = data[index++];
        var value = elementConverter.convert(element, converted);
        if (nullTerminated == null) {
          result.add(value);
          break;
        } else {
          if (element.isNullPtr || value == null || value == 0) {
            if (nullTerminated.includeNull) {
              result.add(value);
            }

            break;
          } else {
            result.add(value);
          }
        }
      }

      return result;
    }

    error(data.type, List);
    return null;
  }
}

class _ObjectConverter<T> extends _Converter<T> {
  final _ClassInfo classInfo;

  _ObjectConverter(this.classInfo);

  T convert(BinaryData data, Map converted) {
    var binaryType = data.type;
    if (binaryType is PointerType && binaryType.type is StructType) {
      binaryType = binaryType.type;
      data = data.value;
    }

    if (binaryType is StructType) {
      var key = new _HashObject(base: data.base, offset: data.offset, typeMirror: classInfo.classMirror);
      var result = converted[key];
      if (result != null) {
        return result;
      }

      var instance = classInfo.classMirror.newInstance(const Symbol(""), const []);
      result = instance.reflectee;
      converted[key] = result;
      var members = classInfo.members;
      for (var key in classInfo.members.keys) {
        var value = data[key];
        var member = members[key];
        value = member.converter.convert(value, converted);
        instance.setField(member.simpleName, value);
      }

      return result;
    }

    var name = MirrorSystem.getName(classInfo.classMirror.simpleName);
    throw new StateError("Unable convert binary type '$binaryType' to '$name'");
    return null;
  }
}

class _StringConverter extends _Converter<String> {
  String convert(BinaryData data, Map converted) {
    if (data.isNullPtr) {
      return null;
    }

    var type = data.type;
    if (type is PointerType) {
      type = type.type;
      data = data[0];
    }

    if (data.isNullPtr) {
      return null;
    }

    if (type is ArrayType) {
      type = type.type;
    }

    if (type is! IntType) {
      error(data.type, String);
    }

    var base = data.base;
    var offset = data.offset;
    var size = type.size;
    var characters = <int>[];
    var index = 0;
    while (true) {
      var value = type.getValue(base, offset);
      if (value == 0) {
        break;
      }

      characters.add(value);
      offset += size;
    }

    return new String.fromCharCodes(characters);
  }
}

abstract class _Converter<T> {
  T convert(BinaryData data, Map converted);

  void error(BinaryType binaryType, Type type) {
    throw new StateError("Unable convert binary type '$binaryType' to '$type'");
  }
}
