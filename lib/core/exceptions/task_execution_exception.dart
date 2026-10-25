/// Ngoại lệ tuỳ chỉnh khi tác vụ nặng thực thi thất bại.
class TaskExecutionException implements Exception {
  const TaskExecutionException(this.message, [this.originalError]);

  final String message;
  final Object? originalError;

  @override
  String toString() =>
      'TaskExecutionException: $message${originalError != null ? ' ($originalError)' : ''}';
}
