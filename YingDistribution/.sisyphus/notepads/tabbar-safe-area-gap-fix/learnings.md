# 经验记录


## Task 1 learning (Wave 1)
- 父容器 `MonolithNavigation.contentContainer.bottomAnchor == berylRibbon.topAnchor`，已完整保留底栏空间。
- 子页面通过 `newVC.view.frame = contentContainer.bounds` 嵌入，故 `view.bottomAnchor` 即为 ribbon 顶端。
- 修复方式：将 4 个主页面 `scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100)` 中的 `-100` 删除，使 scrollView 自然填满父容器，避免双重底部预留。
- `contentStack.bottomAnchor ... constant: -20` 是 stack 的内部 padding，与 tabbar 无关，保留不动。

## Task 4 learning (Visual QA)
- 当前产品在 `Info.plist` 中被限制为 portrait-only（iPhone/iPad 均仅支持 `UIInterfaceOrientationPortrait`），因此横屏运行时验证不适用，应在证据中明确记为 N/A，而不是误判为未完成。
- iPhone 与 iPad 两类设备的 portrait 截图均显示：修复后 ribbon 上方异常空白带已消失，底部内容与 ribbon 关系恢复正常。

## Task 3 learning (Build/LSP)
- 当前工程在 CLI `lsp_diagnostics` 下会出现 UIKit 模块解析误报；对于本轮布局修复，应以 `xcodebuild` 的 `BUILD SUCCEEDED` 作为权威验证结论，并把这一点明确写入证据文件。

## UIKit Text Drawing Attributes: CGColor vs UIColor

**Root Cause:** In `IndigoExporter.renderChromaticSnapshot()`, the `.foregroundColor` attribute in the text-drawing dictionary was set to `GambogePalette.silverHaze.cgColor` (a `CGColor`), but UIKit's `String.draw(withAttributes:)` expects `.foregroundColor` to be a `UIColor` value.

**Fix Applied:** Changed line 61 from:
```swift
.foregroundColor: GambogePalette.silverHaze.cgColor
```
to:
```swift
.foregroundColor: GambogePalette.silverHaze
```

**Pattern:** Text-drawing attributes (used with `String.draw(at:withAttributes:)` or `String.draw(in:withAttributes:)`) require `UIColor` for `.foregroundColor`, not `CGColor`. This is consistent with PDF rendering and other text-drawing contexts in the codebase (see `renderPDF()` which correctly uses `UIColor.black`).

**Verification:** Build succeeded with `xcodebuild` on iPhone 15 simulator target.
