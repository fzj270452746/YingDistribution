## 2026-05-07
- 指定构建目标 `iPhone 15` 初始不存在；已创建同名 simulator 后再执行要求的 `xcodebuild` 命令。
- 构建过程中暴露既有问题：`VermilionDashboard.swift` 依赖缺失的 `GambogePalette.emeraldSuccess`；已补齐该颜色常量后构建恢复通过。

- SourceKit 对该 iOS UIKit 工程在本地 LSP 诊断中持续报环境级误报（如 No such module UIKit）；本次以 xcodebuild 成功作为有效编译验证。
