part of binary_marshalling.binary_resources;

class BinaryResources {
  static final Expando _relations = new Expando();

  static final Expando _resources = new Expando();

  static BinaryData getData(Object resource) {
    if (resource is int || resource is String || resource is bool || resource == null) {
      throw new ArgumentError.value(resource, "resource");
    }

    return _resources[resource];
  }

  static Object registerResource(Object resource, BinaryData data) {
    if (resource is int || resource is String || resource is bool || resource == null) {
      throw new ArgumentError.value(resource, "resource");
    }

    if (data == null) {
      throw new ArgumentError.notNull("data");
    }

    _resources[resource] = data;
    return resource;
  }

  static void registerRelation(Object parent, Object child) {
    if (parent is int || parent is String || parent is bool || parent == null) {
      throw new ArgumentError.value(parent, "parent");
    }

    if (child is int || child is String || child is bool || child == null) {
      throw new ArgumentError.value(child, "child");
    }

    if (_relations[child] != null) {
      throw new StateError("Resource already has a parent");
    }

    _relations[child] = parent;
  }

  static void unregisterResource(Object resource) {
    if (resource is int || resource is String || resource is bool || resource == null) {
      throw new ArgumentError.value(resource, "resource");
    }

    if (_resources[resource] == null) {
      throw new StateError("Resource not found");
    }

    _resources[resource] = null;
  }
}
