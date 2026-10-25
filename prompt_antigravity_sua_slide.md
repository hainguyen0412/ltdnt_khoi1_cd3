# PROMPT CHO ANTIGRAVITY - SỬA HAI BỘ SLIDE LATEX

## Cách dùng

1. Đặt file `dan_y_moi_v2.md` vào **cùng thư mục project** với hai file `.tex` hiện có (bộ thuyết trình 24 slide và bộ báo cáo tuần 14 slide).
2. Dán **Prompt A** cho Antigravity, chờ xong và kiểm tra PDF.
3. Dán **Prompt B** cho bộ báo cáo tuần.
4. Nếu Antigravity hỏi tên file, chỉ vào file `.tex` tương ứng. Bộ thuyết trình là bộ có footer "Chủ đề 03: Xử lý tác vụ nặng với Isolate (hàm compute)" và 24 slide; bộ báo cáo tuần có 14 slide, tiêu đề dạng "1.1., 1.2., 2.1...".

---

# PROMPT A - BỘ SLIDE THUYẾT TRÌNH (bản cũ 22 slide + 2 phụ lục → bản mới 25 slide + 3 phụ lục)

```text
Bạn đang SỬA file LaTeX Beamer hiện có của bộ slide thuyết trình "Xử lý tác vụ nặng với Isolate (hàm compute) để giữ giao diện mượt". KHÔNG viết lại từ đầu. Giữ nguyên theme, bảng màu, font, các macro và phong cách sơ đồ TikZ đã có; chỉ sửa và thêm theo yêu cầu bên dưới.

NGUỒN SỰ THẬT: đọc toàn bộ file `dan_y_moi_v2.md`, đặc biệt mục 0 (tên code thật), mục 1 (quy tắc chung) và PHẦN A (dàn ý từng slide). Nếu có chỗ mâu thuẫn giữa file .tex hiện tại và `dan_y_moi_v2.md`, `dan_y_moi_v2.md` luôn thắng.

MỤC TIÊU: bài thuyết trình tập trung vào CƠ SỞ LÝ THUYẾT, GIẢI THÍCH THIẾT KẾ và CÁCH VIẾT CODE. Demo chỉ 2 slide. Code là minh hoạ gắn với lý thuyết.

=== A. SỬA LỖI HIỆN CÓ (làm trước) ===
A1. Chân trang đang in sai "2 / 1", "3 / 1"... Sửa để in "n / N" với N là tổng số slide thật. Dùng \insertframenumber và \inserttotalframenumber, biên dịch bằng `latexmk -xelatex` (đủ lượt). Phụ lục dùng gói appendixnumberbeamer để không làm tăng N.
A2. Số thập phân bị tách: "16, 6" (slide ngân sách frame và slide kết luận) do viết trong chế độ toán. Tìm toàn bộ chuỗi dạng $...16,6...$ và sửa thành "16,6 ms" ở chế độ văn bản (hoặc 16{,}6). Rà soát toàn file các số khác có dấu phẩy.
A3. Đồng nhất cách viết: "1.500.000.000 (1,5 tỷ)", dùng "tỷ" (không dùng "tỉ"), "16,6 ms" (có dấu phẩy, có khoảng trắng trước ms).
A4. Trang bìa: đổi nhãn "Báo cáo Tuần" thành "Báo cáo chuyên sâu"; bỏ cặp dấu « » bao quanh tiêu đề.
A5. Slide "Nội dung và phân bổ thời gian": mục 2 đang thiếu thời lượng; sửa theo dàn ý (mục 1-2 = 10 phút Thành viên 1; mục 3 = 5 phút Thành viên 2; mục 4 = 5 phút). Giãn bố cục, không để chữ chen nhau.
A6. Code trên slide đang dùng tiếng Việt không dấu ("chay DONG BO", "ham chay o isolate nen", "Dart thuan", "bao loi", "Cam bien khung hinh"...) và có dòng comment bị tự xuống dòng. Thay toàn bộ bằng comment tiếng Anh ngắn, mỗi dòng code ≤ 60 ký tự, theo đúng đoạn code trong `dan_y_moi_v2.md`.
A7. Slide WBS đang ghi "Sơ đồ D1-D5" và "Sơ đồ D6": đó là mã nội bộ, XOÁ khỏi slide. Dùng nội dung ở slide 24 trong dàn ý.
A8. Slide kiến trúc: nhãn "ExecutionException" bị cắt, phải ghi đầy đủ "TaskExecutionException"; hai hộp "AnimationMonitor" và "ResultCard" đang dính nhau, giãn ra ≥ 0,3 cm. Sơ đồ phải khớp mục 0 (HeavyTaskService, TaskResultModel, TaskExecutionException).
A9. Sửa các phát biểu kỹ thuật chưa chính xác (xem mục 1.6 của dàn ý):
    - Slide quy tắc compute: "hàm top-level hoặc static method" → chỉ còn "KHUYẾN NGHỊ top-level" (không ghi static, không ghi "bắt buộc"). Thêm: message, callback và kết quả phải gửi được qua isolate.
    - Mọi chỗ ghi "Heap riêng" → "Bộ nhớ riêng (không chia sẻ đối tượng)". Sơ đồ Thread vs Isolate, sơ đồ luồng compute và slide kết luận đều phải sửa.
    - Slide chi phí/khi nào dùng: bỏ các ngưỡng tự đặt "< 10 ms", "> 1MB"; thay bằng "kéo dài hơn vài mili-giây (có nguy cơ rớt frame)" theo tài liệu Flutter. Slide kết luận: bỏ "> 16,6 ms" như một ngưỡng cứng, thay bằng "đủ nặng để có nguy cơ làm rớt frame".
    - Slide kết quả đo: bỏ "60 FPS", "khớp hoàn toàn với công thức"; dùng "Đứng" / "Mượt" / "Ổn định" và câu "đối chiếu với công thức sau khi có số đo".

=== B. THÊM SLIDE MỚI VÀ ĐÁNH SỐ LẠI ===
Dựng đúng 25 slide chính + 3 slide phụ lục như PHẦN A của dàn ý. Ba slide mới và hai slide tách đôi:
  - Slide 5 (MỚI): "Minh hoạ Event Loop bằng code" (đoạn code in 1, 2, 3, 4 và giải thích).
  - Slide 9 (MỚI): "Giao tiếp giữa các isolate" (sao chép dữ liệu; Isolate.exit; code Isolate.spawn với SendPort/ReceivePort). Nội dung này đang nằm ở phụ lục B1 cũ, chuyển lên đây.
  - Slide 16 (MỚI): "Quyết định thiết kế và cơ sở lý thuyết" (bảng 6 dòng).
  - Slide 11 và 12: hiện đang là hai slide riêng (quy tắc compute, luồng hoạt động compute); GIỮ NGUYÊN là hai slide, không gộp.
Phụ lục: B1 = Câu hỏi dự kiến (thêm 2 dòng mới theo dàn ý), B2 = Các phương án thiết kế đã cân nhắc (MỚI), B3 = Tài liệu tham khảo (MỚI, 5 mục).

BẢNG ÁNH XẠ ĐÁNH SỐ (cũ → mới), dùng để cập nhật MỌI tham chiếu "→ Slide X" và cột "Slide" trong bảng ánh xạ:
  1→1, 2→2, 3→3, 4→4, [mới]→5, 5→6, 6→7, 7→8, [mới]→9, 8→10, 9→11, 10→12, 11→13, 12→14, 13→15, [mới]→16, 14→17, 15→18, 16→19, 17→20, 18→21, 19→22, 20→23, 21→24, 22→25.
Sau khi đánh số lại, mở từng slide có chữ "Slide X" hoặc "→ Slide" và đối chiếu với dàn ý để chắc chắn số đúng (ví dụ: slide thời gian frame trỏ tới demo ở slide 21; bảng ánh xạ ở slide 20 dùng số mới).

=== C. NỘI DUNG TỪNG SLIDE ===
Với mỗi slide 1-25 và B1-B3: tạo/sửa nội dung đúng như PHẦN A của `dan_y_moi_v2.md` (tiêu đề, gạch đầu dòng, bảng, code, mô tả sơ đồ). Mỗi slide có \note{} chứa ý nói ngắn (2-3 ý) lấy từ mục "Ý nói" hoặc suy ra từ nội dung. Một slide một ý chính, tối đa 6 gạch đầu dòng, code tối đa ~14 dòng, cỡ chữ nội dung ≥ 14pt, code \footnotesize.

=== D. NGHIỆM THU (tự kiểm tra rồi mới báo xong) ===
- Biên dịch sạch bằng `latexmk -xelatex`, không lỗi; xử lý các cảnh báo Overfull gây tràn/cắt chữ.
- Footer đúng "n / N" ở mọi slide.
- Không còn các chuỗi: "16, 6", "tỉ", "ExecutionException" đứng một mình, "D1", "D6", "static method", "Heap riêng", "GC", "60 FPS", "< 10ms", "> 1MB", tiếng Việt không dấu trong code.
- Không xuất hiện: executeOnMainThread, executeWithCompute, TaskType, _runHeavyLoopTask, _runHeavyJsonParseTask, SegmentedButton.
- Mọi tham chiếu "→ Slide X" đúng theo đánh số mới.
- Mỗi đoạn code khớp nguyên văn đoạn trong mục 0 của dàn ý; marker (1)(2)... khớp chú thích.
- Cuối cùng, trả lời cho tôi: (1) danh sách thay đổi theo từng mục A1-A9, B, C; (2) mọi cảnh báo còn lại; (3) các chỗ cần tôi tự điền (tên, MSSV, URL repo, số đo, ảnh chụp).
```

---

# PROMPT B - BỘ BÁO CÁO TUẦN (14 slide)

```text
Bạn đang SỬA file LaTeX Beamer hiện có của bộ "Báo cáo Tuần" (14 slide, theo mẫu MauBaocaoTuan: nền trắng, tiêu đề đen, bảng xanh 4472C4, hàng so le xanh nhạt). KHÔNG viết lại từ đầu; giữ nguyên khung, font, màu và bố cục chung. Số slide giữ nguyên 14 và số thứ tự mục (1.1, 1.2, 2.1, ...) giữ nguyên.

NGUỒN SỰ THẬT: đọc toàn bộ `dan_y_moi_v2.md`, đặc biệt mục 0 (tên code thật), mục 1 (quy tắc chung) và PHẦN B (dàn ý B-1 đến B-14). Khi mâu thuẫn, `dan_y_moi_v2.md` thắng.

VẤN ĐỀ CHÍNH: bộ báo cáo này đang mô tả mã nguồn CŨ (hai tác vụ, SegmentedButton, hai hàm executeOnMainThread/executeWithCompute). Mã nguồn thật hiện nay chỉ có MỘT tác vụ và MỘT phương thức HeavyTaskService.run(mode). Slide phải khớp mã nguồn thật.

=== A. ĐỒNG BỘ VỚI MÃ NGUỒN THẬT ===
B1. Xoá mọi nhắc tới: executeOnMainThread, executeWithCompute, TaskType, _runHeavyLoopTask, _runHeavyJsonParseTask, SegmentedButton, _selectedTask, outputSummary, tác vụ parse JSON 50.000 mục. Thay bằng: HeavyTaskService.run(ExecutionMode mode), _heavyLoop, ExecutionMode, TaskResultModel, TaskExecutionException.
B2. Thay toàn bộ các khối code (slide 5, 6, 9, 10, 11, 12) bằng đoạn chuẩn trong mục 0 của dàn ý. Comment code bằng tiếng Anh, dòng ≤ 60 ký tự. Slide 11 chỉ còn MỘT khối code `run` (không còn hai khối cạnh nhau). Slide 5 dùng đoạn AnimationMonitor (abridged) đúng cấu trúc Row.
B3. Slide 13 (ResultCard và demo): ResultCard chỉ có 3 trạng thái (đang tính toán, kết quả kèm thời gian, lỗi màu đỏ). Xoá mô tả "đồng hồ cát", "icon cảnh báo đỏ/tích xanh". Kịch bản demo ghi "khoảng 1 phút" (không ghi "5 phút") và bỏ bước chọn bài toán trên SegmentedButton.

=== B. SỬA PHÁT BIỂU KỸ THUẬT SAI ===
B4. Slide 7 (bảng Thread vs Isolate): XOÁ hàng "Dọn rác bộ nhớ (GC)" (sai: C++ không có GC; từ Dart 2.15 các isolate cùng nhóm có thể dùng chung heap). Sửa "Isolated Heap/Cô lập hoàn toàn" thành "không chia sẻ đối tượng giữa các isolate". Có thể thêm hàng "Event Loop: mỗi isolate một Event Loop".
B5. Slide 9 (quy tắc compute): đổi "Quy tắc bắt buộc... Top-level / Static" thành "khuyến nghị top-level" (không ghi static, không ghi bắt buộc); quy tắc 2 giữ "một tham số".
B6. Slide 4: bỏ chuỗi "Nhận thao tác chạm → Chạy logic Dart → Dựng hình". Thay bằng mô tả hai hàng đợi (Microtask trước, Event queue sau). Bỏ "từ 2-4 giây" cố định.
B7. Slide 8: nói rõ "native: tương đương Isolate.run(() => fun(message)); web: chạy trên event loop hiện tại". Bước 4 viết "kết quả được chuyển về và isolate kết thúc".
B8. Đồng nhất ký hiệu số: "16,6 ms" (dùng dấu phẩy, không dùng "16.6ms"), "1.500.000.000 (1,5 tỷ)" (không dùng "tỉ"). Nếu có số trong chế độ toán, viết 16{,}6 để không bị tách "16, 6".

=== C. THAY PLACEHOLDER BẰNG SƠ ĐỒ THẬT ===
B9. Slide 4: thay "[Chỗ trống chèn ảnh minh hoạ: Sơ đồ Event Loop...]" bằng sơ đồ TikZ: hai hàng đợi (Microtask, Event) → Event Loop → Main Isolate; trong Event queue có các ô Chạm, Vòng lặp nặng (tô đỏ, dài), Frame, Timer; chú thích "Frame phải chờ tác vụ nặng xong".
B10. Slide 8: thay placeholder luồng dữ liệu bằng sơ đồ hai làn: làn Main Isolate (Gọi compute → Vẫn vẽ UI mượt → Nhận kết quả), làn Background Isolate (Spawn + copy → Chạy hàm nặng → Trả kết quả), mũi tên nối theo thứ tự 1→2→3→4.
B11. Slide 6: xoá placeholder ảnh so sánh I/O-bound vs CPU-bound (bảng đã đủ).
B12. Slide 10: đổi placeholder "ảnh chụp cây thư mục" thành cây thư mục dạng chữ (lstlisting) theo mục 0.
B13. Slide 13: GIỮ lại hai placeholder ảnh chụp màn hình (đây là chỗ nhóm tự chèn ảnh thật).

=== D. PHÂN CÔNG VÀ TÀI LIỆU THAM KHẢO ===
B14. Slide 3 (WBS): dùng nội dung ở B-3 của dàn ý (nhất quán với bộ thuyết trình): Thành viên 1: lý thuyết, model, exception, _heavyLoop, HeavyTaskService. Thành viên 2: luồng dữ liệu compute, animation_monitor, result_card, isolate_demo_screen, main, README, đo đạc và demo. Đóng góp 50% / 50%.
B15. Slide 14: tài liệu tham khảo dùng đúng 5 mục trong dàn ý (B3 của Phần A). Mục 4 phải ghi đúng tiêu đề "Improving rendering performance" (không phải "UI Jank and Rendering Performance"). Đặt URL trong \url{} và để chúng tự xuống dòng, không tràn lề.
B16. Slide 2: sửa mục 4 theo B-2 (không còn executeOnMainThread/executeWithCompute).

=== E. NGHIỆM THU ===
- Biên dịch sạch bằng `latexmk -xelatex`, footer "n / 14" đúng, không còn Overfull gây cắt chữ.
- Không còn các chuỗi cấm ở B1, "16.6", "tỉ", "Static", "GC", "Isolated Heap", "[Chỗ trống chèn ảnh" (trừ hai placeholder ở slide 13).
- Code khớp nguyên văn mục 0 của dàn ý.
- Cuối cùng báo cáo cho tôi: danh sách thay đổi theo từng mục B1-B16, cảnh báo còn lại, và những chỗ tôi cần tự điền (tên, MSSV, số đo, ảnh chụp).
```

---

## Ghi chú cho người dùng

- Hai prompt được viết để Antigravity **sửa tại chỗ**, không tạo lại. Nếu nó đề nghị viết lại toàn bộ file, hãy nhắc lại "chỉ sửa tại chỗ, giữ nguyên theme và macro".
- Sau mỗi lần chạy, mở PDF và kiểm tra nhanh: footer, slide kiến trúc, slide có code, các tham chiếu "→ Slide X".
- Bộ thuyết trình hiện **thiếu** đúng 3 slide so với dàn ý v2 (5, 9, 16) và phụ lục B2, B3. Prompt A đã yêu cầu thêm đủ.
- Hai bộ slide đang dùng hai kiểu đánh số khác nhau; không cần đồng bộ số slide giữa hai bộ, chỉ cần đồng bộ **nội dung và tên code**.
