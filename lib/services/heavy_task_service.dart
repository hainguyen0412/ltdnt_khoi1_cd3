import 'package:flutter/foundation.dart';

import '../core/exceptions/task_execution_exception.dart';
import '../models/task_result_model.dart';

/// Hàm truyền vào compute() BẮT BUỘC là top-level (hoặc static)
/// và chỉ nhận đúng 1 tham số.
int _heavyLoop(int iterations) {
  if (iterations <= 0) {
    throw ArgumentError('Số vòng lặp phải lớn hơn 0.');
  }
  var sum = 0;
  for (var i = 0; i < iterations; i++) {
    sum += (i % 7) * (i % 3);
  }
  return sum;
}

class HeavyTaskService {
  /// Chỉnh con số này sao cho Main Thread bị đơ khoảng 2-3 giây trên máy demo.
  static const int defaultIterations = 150000000;

  Future<TaskResultModel> run(
    ExecutionMode mode, {
    int iterations = defaultIterations,
  }) async {
    final stopwatch = Stopwatch()..start();
    try {
      final int sum;
      if (mode == ExecutionMode.mainThread) {
        // Nhường một nhịp để UI kịp vẽ trạng thái "Đang xử lý" trước khi bị đơ.
        await Future<void>.delayed(const Duration(milliseconds: 50));
        sum = _heavyLoop(iterations);
      } else {
        sum = await compute(_heavyLoop, iterations);
      }
      stopwatch.stop();
      return TaskResultModel(
        mode: mode,
        sum: sum,
        durationMs: stopwatch.elapsedMilliseconds,
      );
    } catch (e) {
      stopwatch.stop();
      throw TaskExecutionException('Lỗi khi chạy qua ${mode.label}', e);
    }
  }
}
