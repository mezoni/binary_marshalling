part of binary_marshalling.annotations;

class NativeName {
  final String name;

  const NativeName(this.name);
}

class NullTerminated {
  final bool includeNull;

  const NullTerminated({this.includeNull: false});
}
