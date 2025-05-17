
/// A class that represents an asynchronous value.
///
/// This is used to represent the state of an asynchronous operation, such as
/// loading data from a network, with proper error handling and data representation.
class AsyncValue<T> {
  final T? _data;
  final Object? _error;
  final StackTrace? _stackTrace;
  final bool _isLoading;
  final bool _isEmpty;

    /// Creates an AsyncValue in the initial state.
  const AsyncValue.initial()
      : _data = null,
        _error = null,
        _stackTrace = null,
        _isLoading = false,
        _isEmpty = false;

  /// Creates an AsyncValue in the loading state.
  const AsyncValue.loading()
      : _data = null,
        _error = null,
        _stackTrace = null,
        _isLoading = true,
        _isEmpty = false;

  /// Creates an AsyncValue in the data state.
  const AsyncValue.success(T this._data)
      : _error = null,
        _stackTrace = null,
        _isLoading = false,
        _isEmpty = false;

  /// Creates an AsyncValue in the error state.
  const AsyncValue.error(Object this._error, [this._stackTrace])
      : _data = null,
        _isLoading = false,
        _isEmpty = false;

  /// Creates an AsyncValue in the empty state (no data, not loading, no error).
  const AsyncValue.empty()
      : _data = null,
        _error = null,
        _stackTrace = null,
        _isLoading = false,
        _isEmpty = true;

  /// Whether this AsyncValue is in the data state.
  bool get hasData => _data != null;

  /// Whether this AsyncValue is in the loading state.
  bool get isLoading => _isLoading;

  /// Whether this AsyncValue is in the error state.
  bool get hasError => _error != null;

  /// Whether this AsyncValue is in the empty state.
  bool get isEmpty => _isEmpty;

  /// The value, if available.
  T? get data => _data;

  /// The error, if any.
  Object? get error => _error;

  /// The stack trace associated with the error, if any.
  StackTrace? get stackTrace => _stackTrace;

  /// Maps the value to a different type using [mapper] function.
  AsyncValue<R> map<R>(R Function(T) mapper) {
    if (hasData) {
      return AsyncValue<R>.success(mapper(_data as T));
    } else if (isLoading) {
      return AsyncValue<R>.loading();
    } else {
      return AsyncValue<R>.error(_error!, _stackTrace);
    }
  }

  /// Handle different states with dedicated callbacks.
  R when<R>({
    required R Function(T data) data,
    required R Function() loading,
    required R Function(Object error, StackTrace? stackTrace) error,
  }) {
    if (hasData) {
      return data(_data as T);
    } else if (isLoading) {
      return loading();
    } else {
      return error(_error!, _stackTrace);
    }
  }

  /// Handle different states with dedicated callbacks, with a fallback callback.
  R maybeWhen<R>({
    R Function(T data)? data,
    R Function()? loading,
    R Function(Object error, StackTrace? stackTrace)? error,
    required R Function() orElse,
  }) {
    if (hasData && data != null) {
      return data(_data as T);
    } else if (isLoading && loading != null) {
      return loading();
    } else if (hasError && error != null) {
      return error(_error!, _stackTrace);
    } else {
      return orElse();
    }
  }

  @override
  String toString() {
    if (isLoading) {
      return 'AsyncValue.loading()';
    } else if (hasError) {
      return 'AsyncValue.error($_error)';
    } else if (isEmpty) {
      return 'AsyncValue.empty()';
    } else {
      return 'AsyncValue.success($_data)';
    }
  }
}