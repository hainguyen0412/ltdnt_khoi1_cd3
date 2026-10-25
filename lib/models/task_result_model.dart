/// Hai cách thực thi cùng một tác vụ nặng.
enum ExecutionMode {
  mainThread('Main Thread (chạy trực tiếp)'),
  computeIsolate('Background Isolate (hàm compute)');

  const ExecutionMode(this.label);

  final String label;
}

/// Kết quả của một lần chạy tác vụ.
class TaskResultModel {
  const TaskResultModel({
    required this.mode,
    required this.sum,
    required this.durationMs,
  });

  final ExecutionMode mode;
  final int sum;
  final int durationMs;
}
