## 2026-05-07
- `lsp_diagnostics` 在当前环境下无法正确解析 UIKit/iOS 工程上下文，存在大量与实际 Xcode 构建不一致的误报；本次以 `xcodebuild` 结果作为最终验证依据。
