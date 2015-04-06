part of binary_marshalling.annotations;

class CheckBufferSize {
  final String buffer;

  final String message;

  final String size;

  const CheckBufferSize({this.buffer, this.message, this.size});
}

class CheckResource {
  final String message;

  final String name;

  const CheckResource({this.message, this.name});
}

class NativeName {
  final String name;

  const NativeName(this.name);
}

class NullTerminated {
  final bool includeNull;

  const NullTerminated({this.includeNull: false});
}

class RegisterResource {
  final String message;

  final String name;

  const RegisterResource({this.message, this.name});
}

class UnregisterResource {
  final String message;

  final String name;

  const UnregisterResource({this.message, this.name});
}
