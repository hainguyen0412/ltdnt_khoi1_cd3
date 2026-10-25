# Script đẩy dự án lên GitHub với tên 2 thành viên theo WBS
# Repository: https://github.com/hainguyen0412/ltdnt_khoi1_cd3

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$env:LESSCHARSET = "utf-8"

Write-Host "=== Bắt đầu quy trình Git cho 2 thành viên ===" -ForegroundColor Cyan

# 1. Khởi tạo Git nếu chưa có
if (-not (Test-Path ".git")) {
    git init
    git checkout -b main
}

# 2. Thành viên 1: Khởi tạo khung Flutter
$env:GIT_AUTHOR_NAME = "Nguyễn Đức Hải"
$env:GIT_AUTHOR_EMAIL = "hainguyenduc041205@gmail.com"
$env:GIT_COMMITTER_NAME = "Nguyễn Đức Hải"
$env:GIT_COMMITTER_EMAIL = "hainguyenduc041205@gmail.com"

git add .gitignore .metadata analysis_options.yaml pubspec.yaml pubspec.lock android/ ios/ linux/ macos/ web/ windows/
git commit -m "chore: initial flutter project structure and platform configs"

# 3. Thành viên 1: Nhánh feat/isolate-logic
git checkout -b feat/isolate-logic
git add lib/core/exceptions/task_execution_exception.dart
git commit -m "feat(core): implement TaskExecutionException"

git add lib/models/task_result_model.dart
git commit -m "feat(models): create TaskResultModel and ExecutionMode enum"

git add lib/services/heavy_task_service.dart
git commit -m "feat(service): add _heavyLoop and HeavyTaskService.run"

# Gộp feat/isolate-logic vào main
git checkout main
git merge --no-ff feat/isolate-logic -m "merge: integrate isolate business logic (feat/isolate-logic)"

# 4. Thành viên 2: Nhánh feat/ui
git checkout -b feat/ui
$env:GIT_AUTHOR_NAME = "Phạm Thị Hồng Nhung"
$env:GIT_AUTHOR_EMAIL = "phamnhung7825@gmail.com"
$env:GIT_COMMITTER_NAME = "Phạm Thị Hồng Nhung"
$env:GIT_COMMITTER_EMAIL = "phamnhung7825@gmail.com"

git add lib/ui/widgets/animation_monitor.dart
git commit -m "feat(ui): add AnimationMonitor widget with progress indicators"

git add lib/ui/widgets/result_card.dart
git commit -m "feat(ui): implement ResultCard with three display states"

git add lib/ui/screens/isolate_demo_screen.dart lib/main.dart
git commit -m "feat(screen): assemble IsolateDemoScreen and connect to service"

git add test/widget_test.dart
git commit -m "test: add widget smoke test for IsolateDemoApp"

git add README.md slide/ main.tex main.pdf part_a_text.txt prompt_antigravity_sua_slide.md
git commit -m "docs: add comprehensive README documentation and presentation slides"

# Gộp feat/ui vào main
git checkout main
$env:GIT_AUTHOR_NAME = "Nguyễn Đức Hải"
$env:GIT_AUTHOR_EMAIL = "hainguyenduc041205@gmail.com"
$env:GIT_COMMITTER_NAME = "Nguyễn Đức Hải"
$env:GIT_COMMITTER_EMAIL = "hainguyenduc041205@gmail.com"

git merge --no-ff feat/ui -m "merge: integrate UI components, tests, and documentation (feat/ui)"

# 5. Remote & Push
git remote remove origin 2>$null
git remote add origin https://github.com/hainguyen0412/ltdnt_khoi1_cd3.git
git push -u origin main
git push -u origin feat/isolate-logic
git push -u origin feat/ui

Write-Host "=== Đã hoàn tất đẩy mã nguồn lên GitHub! ===" -ForegroundColor Green
