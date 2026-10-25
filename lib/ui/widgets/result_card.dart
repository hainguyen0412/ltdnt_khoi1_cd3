import 'package:flutter/material.dart';

import '../../models/task_result_model.dart';

/// Hiển thị trạng thái: đang chạy / lỗi / kết quả và thời gian thực thi.
class ResultCard extends StatelessWidget {
  const ResultCard({
    super.key,
    required this.isRunning,
    this.result,
    this.errorMessage,
  });

  final bool isRunning;
  final TaskResultModel? result;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: _buildContent(context),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (isRunning) {
      return const Text('Đang tính toán...', textAlign: TextAlign.center);
    }
    if (errorMessage != null) {
      return Text(
        errorMessage!,
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      );
    }
    final data = result;
    if (data == null) {
      return const Text(
        'Chưa có dữ liệu. Hãy bấm một trong hai nút bên trên.',
        textAlign: TextAlign.center,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hoàn thành: ${data.mode.label}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text('Kết quả: ${data.sum}'),
        Text('Thời gian thực thi: ${data.durationMs} ms'),
      ],
    );
  }
}
