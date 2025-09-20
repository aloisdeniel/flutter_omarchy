sealed class Optional<T> {
  const Optional();

  bool get isSome => this is Some<T>;

  bool get isNone => this is! Some<T>;
}

class Some<T> extends Optional<T> {
  const Some(this.value);
  final T value;
}

class None<T> extends Optional<T> {
  const None();
}
