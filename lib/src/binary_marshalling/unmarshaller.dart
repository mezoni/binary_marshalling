part of binary_marshalling;

enum _KnownType { Bool, Double, Dynamic, Int, List, Num, Object, String }

class BinaryUnmarshaller {
  static Map<TypeMirror, _ClassInfo> _classCache = <TypeMirror, _ClassInfo>{};

  static Map<Type, TypeMirror> _typeCache = <Type, TypeMirror>{};

  static final TypeMirror _binaryDataType = reflectType(BinaryData);

  static final TypeMirror _boolType = reflectType(bool);

  static final TypeMirror _doubleType = reflectType(double);

  static final TypeMirror _dynamicType = currentMirrorSystem().dynamicType;

  static final TypeMirror _intType = reflectType(int);

  static final TypeMirror _listType = reflectType(List);

  static final TypeMirror _numType = reflectType(num);

  static final TypeMirror _stringType = reflectType(String);

  dynamic unmarshall(BinaryData data, Type type) {
    var typeMirror = _reflectType(type);
    var classInfo = _getClassInfo(typeMirror);
    var converter = new _ObjectConverter(classInfo);
    return converter.convert(data, {});
  }

  _ClassInfo _getClassInfo(TypeMirror typeMirror) {
    var classInfo = _classCache[typeMirror];
    if (classInfo == null) {
      if (typeMirror is ClassMirror) {
        var members = <String, _MemberInfo>{};
        classInfo = new _ClassInfo(classMirror: typeMirror, members: members);
        _classCache[typeMirror] = classInfo;
        for (var declaration in typeMirror.declarations.values) {
          if (declaration is VariableMirror) {
            var simpleName = declaration.simpleName;
            var name = MirrorSystem.getName(simpleName);
            var memberType = declaration.type;
            var knownType = _getKnownType(memberType);
            var annotations = [];
            if (declaration.metadata != null) {
              for (var metadata in declaration.metadata) {
                annotations.add(metadata.reflectee);
              }
            }

            var converter = _getConverter(knownType, memberType, annotations: annotations);
            var member =
                new _MemberInfo(classInfo: classInfo, converter: converter, name: name, simpleName: simpleName);
            members[name] = member;
          }
        }
      } else {
        throw new ArgumentError.value(typeMirror, "typeMirror", "Not a ClassMirror");
      }
    }

    return classInfo;
  }

  _Converter _getConverter(_KnownType knownType, TypeMirror typeMirror, {List annotations}) {
    switch (knownType) {
      case _KnownType.Bool:
        return new _GenericConverter<bool>();
      case _KnownType.Double:
        return new _GenericConverter<double>();
      case _KnownType.Int:
        return new _GenericConverter<int>();
      case _KnownType.List:
        var elementMirror = typeMirror.typeArguments[0];
        var elementType = _getKnownType(typeMirror.typeArguments[0]);
        var success = true;
        if (elementType != _KnownType.List) {
          try {
            NullTerminated nullTerminated;
            for (var annotation in annotations) {
              if (annotation is NullTerminated) {
                nullTerminated = annotation;
              }
            }

            var converter = _getConverter(elementType, elementMirror);
            return new _ListConverter(converter, nullTerminated: nullTerminated);
          } catch (s) {
            success = false;
          }
        } else {
          success = false;
        }

        if (!success) {
          var name = MirrorSystem.getName(typeMirror.simpleName);
          var elementName = MirrorSystem.getName(elementMirror.simpleName);
          throw new StateError("Unable create converter to type: '$name<$elementName>'");
        }

        break;
      case _KnownType.Num:
        return new _GenericConverter<num>();
      case _KnownType.Object:
        var classInfo = _getClassInfo(typeMirror);
        return new _ObjectConverter(classInfo);
      case _KnownType.String:
        return new _StringConverter();
      case _KnownType.Dynamic:
        return new _DynamicConverter();
    }

    var name = MirrorSystem.getName(typeMirror.simpleName);
    throw new StateError("Unable create converter to type: '$name'");
  }

  _KnownType _getKnownType(TypeMirror typeMirror) {
    if (typeMirror is ClassMirror) {
      if (typeMirror.isSubtypeOf(_intType)) {
        return _KnownType.Int;
      } else if (typeMirror.isSubtypeOf(_doubleType)) {
        return _KnownType.Double;
      } else if (typeMirror.isSubtypeOf(_numType)) {
        return _KnownType.Num;
      } else if (typeMirror.isSubtypeOf(_boolType)) {
        return _KnownType.Bool;
      } else if (typeMirror.isSubtypeOf(_stringType)) {
        return _KnownType.String;
      } else if (typeMirror.isSubtypeOf(_listType)) {
        return _KnownType.List;
      } else {
        return _KnownType.Object;
      }
    }

    if (typeMirror == _dynamicType) {
      return _KnownType.Dynamic;
    }

    return null;
  }

  TypeMirror _reflectType(Type type) {
    var typeMirror = _typeCache[type];
    if (typeMirror == null) {
      typeMirror = reflectType(type);
      _typeCache[type] = typeMirror;
    }

    return typeMirror;
  }
}
