# DÀN Ý V2 - HAI BỘ SLIDE CHỦ ĐỀ 03: ISOLATE VÀ HÀM `compute`

Tài liệu này là **nguồn sự thật duy nhất** để sửa hai bộ slide đã dựng:

- **Bộ A - Slide thuyết trình** (bản v1 có 24 slide): trọng tâm lý thuyết, code minh hoạ, giải thích thiết kế. Dàn ý ở **PHẦN A**.
- **Bộ B - Báo cáo tuần** (bản có 14 slide, theo mẫu `MauBaocaoTuan`): gọn hơn, có phân công, nội dung, tài liệu tham khảo. Dàn ý ở **PHẦN B**.

Thông điệp xuyên suốt của cả hai bộ:
> Tác vụ nặng chạy đồng bộ trên Main Isolate sẽ chiếm Event Loop nên UI đứng; đưa tác vụ sang Isolate riêng (không chia sẻ đối tượng) thì UI vẫn mượt, đổi lại phải trả chi phí khởi tạo và sao chép dữ liệu.

---

## 0. Nguồn sự thật về mã nguồn (hai bộ slide PHẢI khớp phần này)

Ứng dụng demo chỉ có **một màn hình, một tác vụ (vòng lặp), hai nút, quản lý trạng thái bằng `setState`**. Các tên dưới đây là tên thật trong repo:

| Thành phần | Tên chính xác |
|---|---|
| Hàm tác vụ nặng (top-level) | `_heavyLoop(int iterations)` |
| Service | `HeavyTaskService`, phương thức duy nhất `run(ExecutionMode mode, {int iterations})` |
| Enum | `ExecutionMode { mainThread, computeIsolate }` |
| Model, ngoại lệ | `TaskResultModel`, `TaskExecutionException` |
| UI | `IsolateDemoScreen`, `AnimationMonitor`, `ResultCard`, `main.dart` |

**KHÔNG được xuất hiện** trên slide: `executeOnMainThread`, `executeWithCompute`, `TaskType`, `_runHeavyLoopTask`, `_runHeavyJsonParseTask`, `SegmentedButton`, `_selectedTask`, `outputSummary`, tác vụ parse JSON 50.000 mục. Những thứ này thuộc kế hoạch cũ, đã bỏ.

Cây thư mục:

```text
lib/
├── main.dart
├── core/exceptions/task_execution_exception.dart
├── models/task_result_model.dart
├── services/heavy_task_service.dart
└── ui/
    ├── screens/isolate_demo_screen.dart
    └── widgets/{animation_monitor.dart, result_card.dart}
```

### Code chuẩn để nhúng (comment bằng tiếng Anh, mỗi dòng ≤ 60 ký tự)

`_heavyLoop`:

```dart
int _heavyLoop(int iterations) {            // (1)
  if (iterations <= 0) {
    throw ArgumentError('iterations > 0');  // (4)
  }
  var sum = 0;
  for (var i = 0; i < iterations; i++) {    // (3)
    sum += (i % 7) * (i % 3);
  }
  return sum;                               // (2)
}
```

`HeavyTaskService.run` (rút gọn):

```dart
Future<TaskResultModel> run(ExecutionMode mode,
    {int iterations = defaultIterations}) async {
  final stopwatch = Stopwatch()..start();                    // (5)
  try {
    final int sum;
    if (mode == ExecutionMode.mainThread) {
      await Future<void>.delayed(
          const Duration(milliseconds: 50));                 // (1)
      sum = _heavyLoop(iterations);                          // (2)
    } else {
      sum = await compute(_heavyLoop, iterations);           // (3)
    }
    stopwatch.stop();
    return TaskResultModel(mode: mode, sum: sum,
        durationMs: stopwatch.elapsedMilliseconds);
  } catch (e) {
    throw TaskExecutionException('Task failed', e);          // (4)
  }
}
```

`AnimationMonitor` (rút gọn) và `_handleRun` (rút gọn):

```dart
// AnimationMonitor (abridged)
const Row(children: [
  SizedBox(width: 48, height: 48,
    child: CircularProgressIndicator(strokeWidth: 5)),   // (1)
  Expanded(child: LinearProgressIndicator(minHeight: 8)),
])
```

```dart
// _handleRun (abridged)
setState(() { _isRunning = true; });                     // (2)
try {
  final result = await _service.run(mode);               // (3)
  if (!mounted) return;                                  // (4)
  setState(() => _result = result);
} on TaskExecutionException catch (e) { /* show error */ } // (5)
finally { if (mounted) setState(() => _isRunning = false); }
```

`ResultCard` chỉ có 3 trạng thái: "Đang tính toán...", kết quả (chế độ chạy, tổng, thời gian ms), và thông báo lỗi tô màu đỏ. **Không có** icon đồng hồ cát, tích xanh hay cảnh báo đỏ riêng cho từng chế độ.

---

## 1. Quy tắc chung bắt buộc (áp dụng cho cả hai bộ slide)

1. **Số thập phân kiểu Việt, không bị tách:** viết `16,6 ms` ở chế độ văn bản. Nếu dùng chế độ toán thì `16{,}6\,\mathrm{ms}`. Tuyệt đối không để `$16,6$` vì LaTeX sẽ hiển thị "16, 6" (đang lỗi ở slide 3 và slide 20 của bộ A). Cả hai bộ cùng dùng dấu phẩy ("16,6 ms", không dùng "16.6ms").
2. **Số lần lặp:** luôn ghi `1.500.000.000 (1,5 tỷ)`. Dùng chữ "tỷ", không dùng "tỉ".
3. **Chân trang:** dạng `n / N` với N là tổng số slide thật. Hiện bộ A in sai thành `2 / 1`. Biên dịch bằng `latexmk -xelatex` (tự chạy đủ lượt) và dùng `\insertframenumber / \inserttotalframenumber`. Slide phụ lục có thể dùng gói `appendixnumberbeamer` để không làm tăng N.
4. **Code trên slide:** comment bằng **tiếng Anh**. Không dùng tiếng Việt không dấu (như `// chay DONG BO`, `// ham chay o isolate nen`). Giữ mỗi dòng ≤ 60 ký tự để không bị tự xuống dòng giữa comment. Marker `(1)(2)...` trong code phải khớp chú thích bên cạnh.
5. **Không để mã nội bộ lên slide:** cấm các chuỗi như "Sơ đồ D1-D5", "Sơ đồ D6" (đang lỗi ở slide WBS của bộ A).
6. **Độ chính xác kỹ thuật** (đã đối chiếu tài liệu Flutter/Dart):
   - Hàm truyền vào `compute` **khuyến nghị** là top-level để không kéo theo `this`/UI. **Không** viết "bắt buộc" và **không** viết "hoặc static method". Tài liệu API hiện chỉ yêu cầu `callback`, `message` và kết quả phải gửi được qua isolate.
   - Không viết "heap riêng" như một sự thật tuyệt đối. Viết **"không chia sẻ đối tượng/bộ nhớ giữa các isolate"** hoặc "bộ nhớ riêng về mặt ngôn ngữ". Lý do: từ Dart 2.15, các isolate cùng nhóm có thể dùng chung heap ở mức VM; sự cô lập được áp đặt ở tầng trên.
   - **Cấm** câu "mỗi Isolate dọn rác (GC) độc lập nên giữ mượt UI" và dòng "GC" trong bảng so sánh Thread/Isolate (sai với Dart ≥ 2.15, và C++ không có GC).
   - Trên native, `await compute(fun, message)` tương đương `await Isolate.run(() => fun(message))`. Trên web, `compute` chạy trên event loop hiện tại.
   - Dữ liệu vào được **sao chép**; kết quả của `Isolate.run`/`compute` được chuyển về bằng `Isolate.exit` (không sao chép lại khi có thể).
   - Ngưỡng dùng `compute`: theo tài liệu Flutter, dành cho tác vụ kéo dài **hơn vài mili-giây** (có nguy cơ rớt frame). **Không** ghi các con số tự đặt như "< 10 ms", "> 1 MB".
7. **Không bịa số liệu đo:** không ghi "60 FPS", "khớp hoàn toàn với công thức" khi chưa có số đo. Ô số liệu để `[__] ms`; kết luận dùng từ "mượt", "ổn định", "đứng".
8. **Sơ đồ:** các hộp cách nhau ≥ 0,3 cm, không để chữ dính nhau (đang lỗi ở slide kiến trúc: "AnimationMonitorResultCard"); tên lớp ghi đầy đủ `TaskExecutionException` (đang bị cắt thành "ExecutionException").
9. **Thuật ngữ:** giữ tiếng Anh cho Isolate, Event Loop, Main Thread, compute, message passing. Phần giải thích viết tiếng Việt.

---

# PHẦN A - BỘ SLIDE THUYẾT TRÌNH (25 slide chính + 3 slide phụ lục)

**Phân bổ:** Lý thuyết (kèm code minh hoạ) slide 3-14, Thành viên 1, 10 phút. Thiết kế, giải thích code, demo slide 15-22, Thành viên 2, 5 phút. Kết luận và hỏi đáp slide 23-25, cả hai, 5 phút.

**Slide thêm mới so với bản v1 (đánh dấu NEW):** slide 5, 9, 16. **Slide tách đôi:** slide 11 và 12 (trước là một slide cũ 9 và 10, nay giữ riêng để đỡ chật). Mọi tham chiếu "→ Slide X" phải theo đánh số mới dưới đây.

## Slide 1 - Trang bìa
- Tiêu đề: **Xử lý tác vụ nặng với Isolate (hàm `compute`) để giữ giao diện mượt** (bỏ dấu ngoặc kép « » đang bao quanh tiêu đề).
- Phụ đề: Chủ đề 03 · Khối kiến thức 1: Nền tảng Dart nâng cao và bất đồng bộ.
- Dòng nhãn đầu trang: đổi "Báo cáo Tuần" thành **"Báo cáo chuyên sâu"** (đây là bài thuyết trình, không phải báo cáo tuần). Giữ "Môn: Lập trình Đa nền tảng".
- SVTH (2 thành viên, MSSV), GVHD, "Đà Nẵng, 2026".

## Slide 2 - Nội dung và phân bổ thời gian
1. Vấn đề: UI Jank/Freeze và Event Loop (Thành viên 1)
2. Isolate và hàm `compute()` (Thành viên 1)
3. Từ lý thuyết đến thiết kế và code (Thành viên 2)
4. Demo, kết luận, hỏi đáp (cả hai)
- Ghi người nói và thời lượng rõ ràng: mục 1-2 gộp **10 phút**, mục 3 **5 phút**, mục 4 **5 phút**.
- Thanh thời gian ngang: Lý thuyết 10', Code + demo 5', Hỏi đáp 5' (mốc 0', 10', 15', 20'). Căn chỉnh lại để không chật.
- Nêu câu hỏi dẫn dắt: *"Làm sao tính toán nặng mà giao diện vẫn mượt?"*

---

## PHẦN A1 - CƠ SỞ LÝ THUYẾT: VẤN ĐỀ (Thành viên 1)

## Slide 3 - Frame và ngân sách thời gian (0:50)
- Mỗi frame có ngân sách: 60 Hz → **16,6 ms**; 120 Hz → **8,3 ms**.
- Một frame đi qua *Build → Layout → Paint* (code Dart trên **UI thread**) rồi *Raster* (raster thread, GPU).
- **Jank** = frame vượt ngân sách (giật). **Freeze** = nhiều frame liên tiếp bị bỏ (đứng hình).
- Nguyên nhân gốc: code Dart nặng chạy **đồng bộ** trên UI thread.
- Sơ đồ: bốn ô `Build → Layout → Paint → Raster`; ngoặc trên ba ô đầu "UI thread (code Dart)", ô cuối "Raster thread (GPU)"; thanh "≤ 16,6 ms".
- Khung chốt: "Nếu tác vụ Dart chiếm UI thread lâu hơn 16,6 ms thì không kịp dựng frame mới → Jank/Freeze." (**sửa lỗi "16, 6"**).

## Slide 4 - Dart đơn luồng: Isolate chính và Event Loop (1:00)
- Mỗi **Isolate** có một luồng thực thi Dart và **Event Loop riêng**; Flutter khởi động với **Main Isolate**.
- Hai hàng đợi: **Microtask queue trước**, rồi **Event queue** (chạm, timer, I/O, tín hiệu vẽ frame).
- **Run-to-completion:** mỗi tác vụ chạy đến khi xong, không bị ngắt giữa chừng.
- Tác vụ đồng bộ dài → mọi sự kiện sau nó, kể cả vẽ frame, phải chờ.
- Sơ đồ: hai hàng đợi vào "Event Loop" rồi vào "Main Isolate (UI thread)"; trong Event queue có `Chạm`, **`Vòng lặp nặng` (đỏ, dài)**, `Frame`, `Timer`; chú thích "Frame phải chờ tác vụ nặng xong".

## Slide 5 - Minh hoạ Event Loop bằng code (0:45) **NEW**
Code minh hoạ lý thuyết (không nằm trong app):

```dart
import 'dart:async';

void main() {
  print('1 sync');
  Future(() => print('4 event'));                 // event queue
  scheduleMicrotask(() => print('3 microtask'));  // microtask queue
  print('2 sync');
}
// Output: 1 sync, 2 sync, 3 microtask, 4 event
```

- Code đồng bộ chạy trước (1, 2) vì nằm trong tác vụ hiện tại.
- Microtask chạy **trước** Event queue (3 rồi 4).
- Nếu tác vụ hiện tại kéo dài, các mục trong hai hàng đợi chỉ biết chờ → nền tảng để hiểu Freeze.

## Slide 6 - `async/await` không phải đa luồng (1:00)
- Bảng 3 cột: I/O-bound vs CPU-bound (thời gian đi đâu; `Future/await` đủ chưa; giải pháp), như bản v1.
- Code (comment tiếng Anh):

```dart
Future<int> heavy() async {
  return _heavyLoop(1500000000); // runs SYNCHRONOUSLY
}                                // on the UI thread!
```

- Chốt: *`async` chỉ đổi cách **chờ**, không đổi **nơi chạy**.* Code đồng bộ trong hàm `async` vẫn chiếm UI thread cho đến lần `await` đầu tiên.

## Slide 7 - Hệ quả trên dòng thời gian frame (0:45)
- Sơ đồ hai hàng: (1) Main Thread: vạch xanh → khối **đỏ** "Tác vụ nặng chiếm UI thread: mất frame" → vạch xanh; (2) `compute()`: hàng UI thread toàn vạch xanh, hàng Background isolate có khối xám "Tác vụ nặng chạy ngầm".
- Chú thích: mỗi vạch xanh là một frame hoàn thành trong 16,6 ms. "Nút 1 và Nút 2 ở **slide 21** tái hiện đúng hai hàng này."

---

## PHẦN A2 - CƠ SỞ LÝ THUYẾT: ISOLATE VÀ `compute` (Thành viên 1)

## Slide 8 - Isolate: mô hình đồng thời của Dart (1:00)
- Sơ đồ hai nửa. Trái, "Thread truyền thống (Java, C++)": Thread A, Thread B cùng trỏ vào **Shared memory** (đỏ, "cùng đọc/ghi, cần Lock"). Phải, "Dart Isolate": `Main Isolate` và `Isolate nền`, mỗi ô ghi **"Bộ nhớ riêng (không chia sẻ đối tượng)"** và **"Event Loop riêng"**; giữa hai ô là mũi tên hai chiều "Message passing (SendPort/ReceivePort)".
- Ba ý: **không chia sẻ bộ nhớ** → không race condition, không cần khoá; giao tiếp **chỉ bằng thông điệp**; mỗi isolate có **Event Loop riêng** nên isolate nền bận không làm đứng UI.
- Ghi chú nói (quan trọng): về ngôn ngữ, isolate không thể truy cập đối tượng của isolate khác; từ Dart 2.15 VM gom các isolate vào "isolate group" và có thể dùng chung heap nội bộ, nhưng sự cô lập vẫn được đảm bảo. **Không** nói "GC độc lập".

## Slide 9 - Giao tiếp giữa các isolate (1:00) **NEW**
- Hai isolate trao đổi qua cặp cổng `ReceivePort` (nhận) và `SendPort` (gửi).
- Dữ liệu gửi đi được **sao chép** sang isolate nhận → dữ liệu càng lớn, chi phí càng cao.
- Kết quả có thể được **chuyển giao không sao chép** khi worker kết thúc bằng `Isolate.exit` (cơ chế `Isolate.run`/`compute` dùng).
- Kiểu gửi được: số, chuỗi, bool, `List`, `Map`, đối tượng thuần dữ liệu. **Không** gửi được đối tượng gắn với UI.
- Code minh hoạ cơ chế mức thấp mà `compute` che giấu:

```dart
Future<int> runWithSpawn(int n) async {
  final receive = ReceivePort();                         // (1)
  await Isolate.spawn(_worker, [receive.sendPort, n]);   // (2)
  final result = await receive.first as int;
  receive.close();
  return result;
}

void _worker(List<dynamic> args) {
  final port = args[0] as SendPort;
  port.send(_heavyLoop(args[1] as int));                 // (3)
}
```

- Chú thích: (1) tạo cổng nhận ở isolate gọi; (2) tạo isolate mới, gửi cổng và dữ liệu; (3) worker tính xong rồi gửi kết quả về.
- Ý nói: cách này đúng nhưng dài dòng, `compute` gói toàn bộ vào một lời gọi (slide 10-12).

## Slide 10 - Ba cách dùng Isolate (0:50)
- Bảng: `Isolate.spawn` (thấp; worker sống lâu), `Isolate.run` (Dart ≥ 2.19; tác vụ một lần), `compute()` (Flutter; native tương đương `Isolate.run`, **web chạy trên event loop hiện tại**).
- Code (comment tiếng Anh, ngắn để không xuống dòng):

```dart
final r1 = await Isolate.run(() => heavy(n)); // plain Dart
final r2 = await compute(heavy, n);           // Flutter
```

- Chốt: nhóm chọn **`compute()`** vì tác vụ chạy một lần và API gọn nhất.

## Slide 11 - `compute()`: chữ ký và quy tắc (0:50)

```dart
Future<R> compute<M, R>(
  ComputeCallback<M, R> callback, // runs in the background isolate
  M message,                      // single input value
);
```

4 quy tắc (ghi rõ mức độ):
1. **Khuyến nghị:** `callback` là hàm **top-level**, không phải closure bắt `this`/`BuildContext`.
2. Chỉ **một tham số** `message`; cần nhiều giá trị thì gói vào `List`, `Map` hoặc class đơn giản.
3. `message`, `callback` và kết quả phải **gửi được** giữa các isolate (có thể được sao chép sâu nếu cần).
4. Lỗi ném trong isolate nền được **ném lại ở chỗ `await`** → bắt bằng `try/catch`.

## Slide 12 - Luồng hoạt động của `compute()` (0:50)
- Sơ đồ hai làn. Làn trên "Main Isolate (UI thread)": `1. Gọi compute` → `Vẫn vẽ UI mượt` (Event Loop không bị chiếm) → `4. Nhận kết quả (setState)`. Làn dưới "Background Isolate": `2. Spawn + copy` → `3. Chạy hàm nặng` (không gian bộ nhớ riêng) → `Trả kết quả (isolate kết thúc)`.
- Hai ý: đầu vào được **sao chép**; kết quả được **chuyển giao về** và isolate kết thúc.

## Slide 13 - Chi phí và khi nào nên dùng (0:45)
- `T_compute ≈ T_spawn + T_copy + T_task + T_return` so với `T_main ≈ T_task` (nhưng **chặn UI**).
- **Nên dùng:** parse JSON lớn, xử lý ảnh, mã hoá/nén, sắp xếp/lọc danh sách lớn, vòng lặp tính toán nặng. Theo tài liệu Flutter: dành cho tác vụ kéo dài **hơn vài mili-giây** (có nguy cơ rớt frame).
- **Không nên:** tác vụ rất nhẹ (chi phí spawn lớn hơn lợi ích), I/O thuần (dùng `async/await`), tác vụ cần truy cập widget/`BuildContext`. **Bỏ** mọi ngưỡng tự đặt như "< 10 ms", "> 1 MB".
- Chốt: **`compute` giữ UI mượt, KHÔNG làm tác vụ chạy nhanh hơn.**

## Slide 14 - Cạm bẫy và giới hạn (0:25)
- **Closure bắt biến ngoài** (`this`, `BuildContext`) → kéo theo trạng thái không gửi được; chỉ truyền dữ liệu tối thiểu.
- **Dữ liệu lớn** → tốn thời gian sao chép; trả kết quả gọn.
- **Plugin/platform channel** trong isolate nền cần khởi tạo riêng (`BackgroundIsolateBinaryMessenger`).
- **Flutter Web:** `compute` chạy cùng event loop, không tạo luồng mới.
- **Debug mode** chậm hơn nhiều → đo ở `--profile`/`--release`.

---

## PHẦN A3 - TỪ LÝ THUYẾT ĐẾN THIẾT KẾ VÀ CODE (Thành viên 2)

## Slide 15 - Kiến trúc ứng dụng và lý do tách tầng (0:15)
- Sơ đồ xếp dọc: `main.dart` → khung "ui/" chứa `IsolateDemoScreen` (State, 2 nút), `AnimationMonitor`, `ResultCard` → mũi tên "gọi `run(mode)`" → khung "services, models, core" chứa `HeavyTaskService` (Main Thread và compute), `TaskResultModel`, **`TaskExecutionException`** (ghi đủ tên). Ba hộp trong mỗi khung cách nhau rõ ràng.
- Ý nói: UI không biết chi tiết về isolate; toàn bộ cơ chế nằm trong `HeavyTaskService` (Single Responsibility).

## Slide 16 - Quyết định thiết kế và cơ sở lý thuyết (0:40) **NEW**
Bảng 3 cột (Quyết định / Lý do / Cơ sở lý thuyết):

| Quyết định thiết kế | Lý do | Cơ sở (slide) |
|---|---|---|
| Hai nút dùng **chung một hàm** `_heavyLoop` | So sánh công bằng: chỉ khác *nơi chạy* | 7 |
| Tác vụ là **vòng lặp CPU-bound**, chỉ truyền/nhận `int` | Tách yếu tố tính toán khỏi chi phí sao chép; chỉnh độ nặng bằng một hằng số | 6, 9, 13 |
| Hàm **top-level, một tham số** | Theo khuyến nghị của `compute`, không kéo theo đối tượng UI | 11, 14 |
| Dùng **`compute`**, không dùng `Isolate.spawn` | Tác vụ chạy một lần, API gọn | 10 |
| `await Future.delayed(50ms)` ở nhánh Main Thread | Nhường Event Loop để UI kịp vẽ "Đang tính toán" trước khi bị chặn | 4, 5 |
| `AnimationMonitor` làm "cảm biến" | Indicator vẽ lại theo từng frame; UI thread bị chặn thì đứng | 3, 7 |

- Ý nói: mọi lựa chọn đều có lý do từ lý thuyết. Các phương án khác đã cân nhắc nằm ở slide phụ lục B2.

## Slide 17 - Code 1: `_heavyLoop` (0:30)
- Tệp: `lib/services/heavy_task_service.dart`. Code chuẩn ở mục 0.
- Giải thích:
  1. **Hàm top-level**, một tham số → đúng khuyến nghị của `compute`. → Slide 11
  2. Vào/ra đều là `int` → **gửi được** giữa các isolate. → Slide 9
  3. Vòng lặp **đồng bộ, CPU-bound**, không có `await` → chạy ở Main Isolate sẽ **chiếm Event Loop**. → Slide 4, 6
  4. `ArgumentError` ném trong isolate nền được **ném lại ở nơi `await`**. → Slide 11
- Chốt nhỏ: cùng một hàm cho cả hai nút → so sánh công bằng.

## Slide 18 - Code 2: `HeavyTaskService.run`, hai cách chạy (0:50)
- Tệp: `lib/services/heavy_task_service.dart`. Code chuẩn ở mục 0.
- Giải thích:
  1. `Future.delayed` **nhường Event Loop một nhịp** để UI vẽ "Đang tính toán" *trước khi* bị chặn. → Slide 4, 5
  2. Gọi trực tiếp → chạy **ngay trên Main Isolate** → chiếm UI thread → **Freeze**. → Slide 3, 7
  3. `compute(...)` → **tạo isolate nền**, sao chép `iterations`, chạy `_heavyLoop`, trả kết quả; Main Isolate vẫn **vẽ frame**. → Slide 12
  4. Lỗi ở cả hai nhánh được **bọc** thành `TaskExecutionException` rồi ném lên UI. → Slide 11
  5. `Stopwatch` đo **thời gian thực**, gồm cả chi phí spawn/copy ở nhánh `compute`. → Slide 13

## Slide 19 - Code 3: giao diện, "cảm biến" và điều khiển (0:35)
- Tệp: `animation_monitor.dart`, `isolate_demo_screen.dart`. Hai khối code chuẩn ở mục 0.
- Giải thích:
  1. Indicator vẽ lại **mỗi frame** → là "cảm biến": UI thread bị chặn thì vòng quay **đứng**. → Slide 3, 7
  2. `setState` chuyển UI sang trạng thái đang chạy và **khoá hai nút** để tránh chạy chồng.
  3. `await` ở UI **không chặn** Event Loop (chỉ chờ Future); việc nặng nằm ở service. → Slide 6
  4. Kiểm tra `mounted` vì widget có thể đã bị huỷ khi Future hoàn thành.
  5. Bắt đúng kiểu ngoại lệ của nhóm; `finally` luôn mở khoá nút.

## Slide 20 - Bảng ánh xạ: Lý thuyết → Code (0:30)

| Khái niệm lý thuyết | Thể hiện trong code | Slide |
|---|---|---|
| Event Loop chạy run-to-completion | `await Future.delayed(50ms)` trước tác vụ ở Main Thread | 4, 18 |
| Tác vụ CPU-bound | `_heavyLoop` (vòng lặp đồng bộ, không `await`) | 6, 17 |
| Hàm top-level, một tham số | `_heavyLoop(int iterations)` truyền vào `compute` | 11, 17 |
| Không chia sẻ đối tượng, chỉ truyền thông điệp | Chỉ gửi `int` đi và nhận `int` về | 8, 9, 17 |
| Lỗi lan truyền về nơi `await` | `try/catch` → `TaskExecutionException` | 11, 18 |
| Chi phí spawn/copy | `Stopwatch` đo thời gian thực của cả hai nhánh | 13, 18 |
| Ngân sách frame 16,6 ms | `AnimationMonitor` làm "cảm biến" UI thread | 3, 19 |

- Chốt: mỗi dòng code đều có cơ sở lý thuyết.

---

## PHẦN A4 - DEMO VÀ KẾT LUẬN

## Slide 21 - Demo: cùng một tác vụ, hai cách chạy (0:40, chạy app thật)
- Ba bước: (1) quan sát vòng quay mượt; (2) bấm **Nút 1 (Main Thread)** → vòng quay **đứng**; (3) bấm **Nút 2 (`compute`)** → vòng quay **vẫn mượt**.
- Hai ảnh chụp thật: màn hình app và biểu đồ performance overlay khi bấm Nút 1 (giữ placeholder nếu chưa có ảnh).
- Dòng cấu hình: thiết bị `[__]`, chế độ `--profile`, `iterations = 1.500.000.000 (1,5 tỷ)`.
- Lưu ý: chạy trên thiết bị thật hoặc emulator, **không dùng Chrome**.

## Slide 22 - Kết quả đo (0:30)

| | **Nút 1: Main Thread** | **Nút 2: `compute`** |
|---|---|---|
| Thời gian thực thi (ms) | `[__]` | `[__]` |
| Vòng quay animation | Đứng | Mượt |
| UI thread (overlay) | Vượt 16,6 ms nhiều frame | Ổn định |

- `compute` **không làm tác vụ nhanh hơn** (có thể chậm hơn chút do spawn/copy) nhưng **UI luôn phản hồi**.
- Sau khi có số đo, đối chiếu với công thức ở slide 13. **Không** ghi "60 FPS" hay "khớp hoàn toàn" nếu chưa đo.

## Slide 23 - Kết luận (0:30)
1. Tác vụ nặng trên Main Isolate **chiếm Event Loop** → Jank/Freeze.
2. **Isolate** (không chia sẻ bộ nhớ, Event Loop riêng, message passing) giải quyết tận gốc; `compute()` là cách gọn nhất cho tác vụ một lần.
3. Có đánh đổi: tốn chi phí spawn/copy → chỉ dùng khi tác vụ **đủ nặng để có nguy cơ làm rớt frame**.
- Hướng mở rộng: `Isolate.spawn` cho worker sống lâu; chạy plugin trong isolate nền.

## Slide 24 - Phân công và mã nguồn
- Thành viên 1: Business Logic, lý thuyết; `task_execution_exception.dart`, `task_result_model.dart`, `heavy_task_service.dart`; slide 3-14.
- Thành viên 2: UI, State, demo; `isolate_demo_screen.dart`, `animation_monitor.dart`, `result_card.dart`, `main.dart`, README; slide 15-22.
- Bảng WBS (TT, Họ và tên, Nội dung, Đóng góp 50% / 50%), liên kết repo `[URL repo]`. **Bỏ** "Sơ đồ D1-D5", "Sơ đồ D6".

## Slide 25 - Hỏi đáp
- **Cảm ơn thầy/cô đã lắng nghe, xin mời đặt câu hỏi.**

---

## PHỤ LỤC (backup, dùng `\appendix`, không tính vào N)

## Slide B1 - Câu hỏi dự kiến và trả lời ngắn

| Câu hỏi | Trả lời ngắn |
|---|---|
| `compute` có làm nhanh hơn không? | Không. Nó giữ UI mượt; còn tốn thêm chi phí spawn/copy. |
| Sao `Future`/`async` chưa đủ? | `async` chỉ nhường lúc chờ I/O; tác vụ CPU-bound vẫn chiếm UI thread. |
| Hàm truyền vào có bắt buộc top-level không? | Không bắt buộc về kỹ thuật (closure vẫn gửi được nếu mọi giá trị nó bắt đều gửi được), nhưng khuyến nghị để không kéo theo `this`/UI. |
| Lỗi trong isolate nền đi đâu? | Được ném lại ở chỗ `await`, bắt bằng `try/catch`. |
| `compute` trên Flutter Web? | Chạy cùng event loop hiện tại, không tạo luồng mới. |
| Khi nào dùng `Isolate.spawn` thay `compute`? | Worker sống lâu, trao đổi thông điệp nhiều lần. |
| Isolate nền có cập nhật UI trực tiếp được không? | Không. Chỉ trả kết quả về, UI cập nhật ở Main Isolate. |
| Isolate có thật sự dùng bộ nhớ riêng không? | Về ngôn ngữ: có, không đối tượng nào được truy cập chéo. Về VM: từ Dart 2.15 các isolate cùng nhóm có thể dùng chung heap nội bộ, nhưng sự cô lập vẫn được đảm bảo ở tầng trên. |

## Slide B2 - Các phương án thiết kế đã cân nhắc

| Phương án | Vì sao không chọn |
|---|---|
| Thêm tác vụ parse JSON | Đề cho phép chọn một; vòng lặp dễ chỉnh độ nặng và tách rõ yếu tố tính toán khỏi chi phí sao chép |
| Dùng thư viện state management (Provider, Bloc...) | Một màn hình, một trạng thái; `setState` đủ, thư viện không thêm giá trị lý thuyết |
| Dùng `Isolate.spawn` | Tác vụ chạy một lần; `compute` gọn hơn, không phải tự quản lý cổng |
| Bộ đếm FPS tự viết | Vòng quay đã đủ trực quan; có thể bật `showPerformanceOverlay` khi cần số liệu |

## Slide B3 - Tài liệu tham khảo
1. Flutter Docs, *Concurrency and isolates*. https://docs.flutter.dev/perf/isolates
2. Flutter API, *compute function*. https://api.flutter.dev/flutter/foundation/compute.html
3. Dart Docs, *Concurrency in Dart*. https://dart.dev/language/concurrency
4. Flutter Docs, *Improving rendering performance*. https://docs.flutter.dev/perf/rendering-performance
5. Flutter Docs, *Flutter's build modes*. https://docs.flutter.dev/testing/build-modes

---

# PHẦN B - BỘ BÁO CÁO TUẦN (14 slide, theo mẫu MauBaocaoTuan)

**Phong cách:** giữ khung mẫu hiện có (nền trắng, tiêu đề đen, bảng xanh `4472C4`, hàng so le xanh nhạt). Mỗi slide ngắn, ít chữ, code rút gọn. Số thứ tự mục giữ nguyên (1.1, 1.2, ...). Áp dụng **mọi quy tắc ở mục 1** và **nguồn sự thật ở mục 0**.

## B-1 - Trang bìa
- Giữ nguyên bố cục hiện có ("Báo cáo Tuần", trường, khoa, môn, tên chủ đề, SVTH 2 thành viên, "Đà Nẵng, 2026").

## B-2 - Nội dung báo cáo
1. Phân công công việc (WBS) và kiến trúc thư mục dự án
2. Phần 1: Main Thread, Event Loop và hiện tượng UI Jank/Freeze (ngưỡng 16,6 ms; `AnimationMonitor`; vì sao `async/await` không giải quyết tác vụ CPU-bound)
3. Phần 2: Dart Isolate và hàm `compute()` (không chia sẻ bộ nhớ, message passing; chu trình 4 bước; viết hàm cho `compute`)
4. Phần 3: Đối chiếu code - hai nhánh của `HeavyTaskService.run` (Main Thread và `compute`); điều phối `setState`, kiểm tra `mounted`, xử lý ngoại lệ
5. Phần 4: Demo, kết quả đo, tổng kết và tài liệu tham khảo
- **Sửa:** mục 4 cũ ghi `executeOnMainThread` và `executeWithCompute` → thay bằng "hai nhánh của `HeavyTaskService.run`".

## B-3 - Phân công công việc (WBS)
Bảng 4 cột (TT, HỌ VÀ TÊN, NỘI DUNG PHỤ TRÁCH, ĐÓNG GÓP), nhất quán với slide 24 của Bộ A:
- Thành viên 1 (50%): nghiên cứu lý thuyết Main Thread, Event Loop, Isolate; thiết kế `task_result_model.dart`, `task_execution_exception.dart`; viết `_heavyLoop` và `HeavyTaskService`.
- Thành viên 2 (50%): nghiên cứu luồng dữ liệu của `compute()`; xây dựng `animation_monitor.dart`, `result_card.dart`, `isolate_demo_screen.dart`, `main.dart`; viết README, đo đạc và quay demo.

## B-4 - 1.1. Main Thread, Event Loop và ngưỡng 16,6 ms
- Trái: Flutter chạy Dart trên **Main Isolate** (UI thread). Event Loop lấy việc từ **Microtask queue trước**, rồi **Event queue** (chạm, timer, I/O, tín hiệu vẽ frame). **Bỏ** chuỗi "Nhận thao tác chạm → Chạy logic Dart → Dựng hình" (quá đơn giản và dễ gây hiểu sai).
- Quy tắc 16,6 ms: `1000 ms / 60 ≈ 16,6 ms` (dùng dấu phẩy). Hàm chiếm Main Thread quá ngân sách → Event Loop bị kẹt → UI Freeze. **Bỏ** câu "từ 2-4 giây" cố định; thay bằng "kéo dài vài giây (tuỳ thiết bị và `iterations`)".
- Phải: **thay placeholder bằng sơ đồ Event Loop** (hai hàng đợi vào Event Loop vào Main Isolate; ô đỏ "Vòng lặp nặng" nằm trong Event queue; "Frame phải chờ").

## B-5 - 1.2. Minh hoạ trong code: `AnimationMonitor`
- Mục đích: quan sát bằng mắt việc Event Loop có kịp vẽ mỗi frame hay không. `CircularProgressIndicator` và `LinearProgressIndicator` được vẽ lại theo từng frame trên UI thread; Main Thread nghẽn thì cả hai **đứng**.
- Code: khối `AnimationMonitor (abridged)` chuẩn ở mục 0 (không dùng đoạn `Card(... Row(...))` sai cấu trúc hiện có).

## B-6 - 1.3. Vì sao `async/await` không chống đơ cho tác vụ nặng?
- Bảng I/O-bound vs CPU-bound ngắn gọn; chốt "`async` đổi cách chờ, không đổi nơi chạy".
- Code (nhánh Main Thread của `run`):

```dart
// main thread branch of HeavyTaskService.run
await Future<void>.delayed(const Duration(milliseconds: 50));
sum = _heavyLoop(iterations); // synchronous: blocks the UI thread
```

- **Bỏ** placeholder ảnh "So sánh I/O-bound vs CPU-bound" (bảng đã đủ).

## B-7 - 2.1. Kiến trúc Isolate và khác biệt với Thread truyền thống
- Bảng 3 hàng (tiêu chí / Thread truyền thống / Dart Isolate):
  - Vùng nhớ: dùng chung (Shared Memory) / **không chia sẻ đối tượng** giữa các isolate.
  - Rủi ro xung đột: dễ Race Condition, cần Lock/Mutex / không có xung đột trên đối tượng, không cần khoá.
  - Giao tiếp: đọc/ghi trực tiếp cùng ô nhớ / truyền thông điệp (Message Passing) qua Port.
  - (Hàng thứ tư tuỳ chọn) Event Loop: không có khái niệm tương ứng / **mỗi isolate một Event Loop**.
- **XOÁ hàng "Dọn rác bộ nhớ (GC)"** (sai: C++ không có GC; Dart ≥ 2.15 các isolate cùng nhóm có thể dùng chung heap).
- Sửa chữ "Isolated Heap" thành "không chia sẻ đối tượng".

## B-8 - 2.2. `compute()` và chu trình 4 bước
- Lý do dùng: thay vì tự `Isolate.spawn` và quản lý `SendPort/ReceivePort`, `compute()` gói toàn bộ quy trình. Native tương đương `Isolate.run(() => fun(message))`; web chạy trên event loop hiện tại.
- 4 bước: **Spawn** → **Copy** (sao chép `message` sang isolate mới) → **Execute** (Main Isolate vẫn vẽ UI) → **Return & Kill** (kết quả được chuyển về, isolate kết thúc).
- **Thay placeholder bằng sơ đồ hai làn 4 bước** (như slide 12 của Bộ A).

## B-9 - 2.3. Áp dụng vào code: viết hàm cho `compute()`
- Hai quy tắc, ghi đúng mức: (1) **khuyến nghị** hàm top-level để không kéo theo ngữ cảnh Widget/Class (**bỏ "Static" và bỏ chữ "bắt buộc"**); (2) đúng **một tham số**.
- Code: `_heavyLoop` chuẩn ở mục 0. **Xoá** hàm `_runHeavyJsonParseTask`.

## B-10 - 3.1. Cấu trúc thư mục, Model và ngoại lệ
- Cây thư mục (chữ, không cần ảnh): như mục 0.
- Code rút gọn (nhãn ngắn để tránh ký tự Việt trong code):

```dart
enum ExecutionMode { mainThread, computeIsolate }   // + label

class TaskResultModel {
  final ExecutionMode mode;
  final int sum;
  final int durationMs;
}

class TaskExecutionException implements Exception {
  final String message;
  final Object? originalError;
}
```

- **Xoá** `enum TaskType`, trường `taskType`, `outputSummary`.

## B-11 - 3.2. Trọng tâm code: hai nhánh của `HeavyTaskService.run`
- Một khối code duy nhất: `run` chuẩn ở mục 0 (không còn hai hàm `executeOnMainThread`/`executeWithCompute`, không còn `switch`).
- Ba gạch: nhánh `mainThread` gọi thẳng `_heavyLoop` (UI đơ); nhánh `computeIsolate` dùng `await compute(_heavyLoop, iterations)` (UI mượt); cả hai bọc lỗi bằng `TaskExecutionException`.

## B-12 - 3.3. Điều phối State tại `IsolateDemoScreen`
- Code: `_handleRun` chuẩn ở mục 0 (đã rút gọn, đúng với `_service.run(mode)`).
- Ba kỹ thuật: `_isRunning` khoá hai nút, chống bấm trùng; kiểm tra `mounted` trước `setState`; bắt `on TaskExecutionException` và `finally` luôn tắt trạng thái loading. **Bỏ** mọi nhắc tới `SegmentedButton`.

## B-13 - 4.1. Ứng dụng demo, kết quả và kịch bản
- `ResultCard`: ba trạng thái (đang tính toán; kết quả kèm chế độ chạy và thời gian đo bằng `Stopwatch`; lỗi tô đỏ). **Bỏ** mô tả "đồng hồ cát", "icon cảnh báo đỏ/tích xanh".
- Kịch bản demo (khoảng 1 phút, không phải "5 phút"): (1) quan sát vòng quay mượt; (2) bấm Nút 1 → đứng; (3) bấm Nút 2 → mượt. **Bỏ** bước "Chọn bài toán trên SegmentedButton".
- Bảng đo (`[__] ms` ở hai ô thời gian) và hai placeholder ảnh chụp thật (giữ lại, đây là chỗ nhóm tự chèn).

## B-14 - 4.2. Tổng kết và tài liệu tham khảo
- Khi nào dùng `compute()`: tác vụ CPU-bound kéo dài hơn vài mili-giây, có nguy cơ rớt frame. Khi nào không: tác vụ nhỏ (chi phí spawn/copy lớn hơn), I/O thuần.
- Tài liệu tham khảo: dùng **5 mục như slide B3 của Bộ A**. Lưu ý mục 4 phải ghi đúng tiêu đề **"Improving rendering performance"** (bản cũ ghi sai thành "UI Jank and Rendering Performance").

---

## Việc nhóm cần tự điền

Tên môn (nếu khác), giảng viên, họ tên và MSSV, `[URL repo]`, thiết bị demo, số liệu đo (`[__] ms`), ảnh chụp màn hình và performance overlay. Nếu đổi `defaultIterations` trong code, sửa lại con số `1.500.000.000` ở slide 6 và slide 21 (Bộ A) và slide B-6 (Bộ B).
