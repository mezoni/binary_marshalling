binary_marshalling
=====

Binary marshalling intended to help transforming binary data to plain Dart objects.

Version: 0.0.3

Example:

```dart
import "package:binary_marshalling/annotations.dart";
import "package:binary_marshalling/binary_marshalling.dart";
import "package:binary_types/binary_types.dart";

void main() {
  var _unmarshaller = new BinaryUnmarshaller();
  var types = new BinaryTypes();
  var helper = new BinaryTypeHelper(types);
  helper.declare(_header);
  final data = types["FOO"].alloc(const []);
  final string = helper.allocString("Hello");
  final user = helper.allocString("John Locke");
  var index = 0;
  for (var c in "Hey!".codeUnits) {
    data["ca"][index++].value = c;
  }

  data["ca"][index++].value = 0;
  data["cp"].value = string;
  data["self"].value = data;
  data["rg_user"].value = user;
  var count = 3;
  final strings = types["char*"].array(count + 1).alloc(const []);

  // For preventing a deallocation (auto freeing)
  final heap = [];
  for (var i = 0; i < count; i++) {
    var object = helper.allocString("String $i");
    // For preventing a deallocation (auto freeing)
    heap.add(object);
    strings[i].value = object;
  }

  for (var i = 0; i < 3; i++) {
    data["cb"][i].value = 41;
  }

  data["strings"].value = strings;

  // Now we have filled "struct foo"
  // It was hard work
  // Unmarshall it to "Foo"
  // WITH JUST ONE LINE OF CODE
  Foo foo = _unmarshaller.unmarshall(data, Foo);

  // Prints
  print("This is unmarshalled Foo:");
  print("a      : ${foo.a}");
  print("ba     : ${foo.ba}");
  print("ca     : ${foo.ca}");
  print("cb     : ${foo.cb}");
  print("cp     : ${foo.cp}");
  print("i      : ${foo.i}");
  print("self   : ${foo.self}");
  print("strings: ${foo.strings}");
  print("user   : ${foo.user}");
}

const String _header = '''
typedef struct foo {
  _Bool ba[3];

  // For string
  char ca[10];

  // For bytes
  char cb[10];

  struct foo *self;

  int i;

  char *cp;

  // Ptr to null terminated array of strings
  char **strings;

  char *rg_user;  
} FOO;
''';

class Foo {
  String _magic = "41";

  int a = 41;

  List<bool> ba;

  String ca;

  List<int> cb;

  String cp;

  @NullTerminated()
  List<String> strings;

  int i;

  Foo self;

  @NativeName("rg_user")
  String user;
}

```

Output:

```
This is unmarshalled Foo:
ba     : [false, false, false]
ca     : Hey!
cb     : [41, 41, 41, 0, 0, 0, 0, 0, 0, 0]
cp     : Hello
i      : 0
self   : Instance of 'Foo'
strings: [String 0, String 1, String 2]
```