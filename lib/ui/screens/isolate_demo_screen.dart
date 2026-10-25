import 'package:flutter/material.dart';

import '../../core/exceptions/task_execution_exception.dart';
import '../../models/task_result_model.dart';
import '../../services/heavy_task_service.dart';
import '../widgets/animation_monitor.dart';
import '../widgets/result_card.dart';

class IsolateDemoScreen extends StatefulWidget {
  const IsolateDemoScreen({super.key});

  @override
  State<IsolateDemoScreen> createState() => _IsolateDemoScreenState();
}

class _IsolateDemoScreenState extends State<IsolateDemoScreen> {
  final HeavyTaskService _service = HeavyTaskService();

  bool _isRunning = false;
  TaskResultModel? _result;
  String? _errorMessage;

  Future<void> _handleRun(ExecutionMode mode) async {
    if (_isRunning) return;
    setState(() {
      _isRunning = true;
      _errorMessage = null;
    });

    try {
      final result = await _service.run(mode);
      if (!mounted) return;
      setState(() => _result = result);
    } on TaskExecutionException catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = e.toString());
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Lỗi không xác định: $e');
    } finally {
      if (mounted) setState(() => _isRunning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Isolate & compute()')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AnimationMonitor(),
              const SizedBox(height: 24),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
                onPressed: _isRunning
                    ? null
                    : () => _handleRun(ExecutionMode.mainThread),
                child: const Text('Nút 1: Chạy trên Main Thread (đơ UI)'),
              ),
              const SizedBox(height: 12),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Colors.teal),
                onPressed: _isRunning
                    ? null
                    : () => _handleRun(ExecutionMode.computeIsolate),
                child: const Text('Nút 2: Chạy bằng compute() (mượt)'),
              ),
              const SizedBox(height: 24),
              ResultCard(
                isRunning: _isRunning,
                result: _result,
                errorMessage: _errorMessage,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
