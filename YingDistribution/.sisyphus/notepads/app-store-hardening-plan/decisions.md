## 2026-05-07
- 将 `VermilionDashboardVM` 标记为 `@MainActor`，并在 distiller 回调里显式切回主线程，确保 `@Published` 状态更新安全。
- `savePreset(name:)` 以当前内存态 `presets` 做重名拦截，命中时返回 `false`，避免修改 archivist 侧实现。
- 为满足构建验证，补齐 `GambogePalette.emeraldSuccess` 到现有 `verdantTeal` 别名，不改动业务流程。

- 历史页采用 `UITableView` 自定义卡片 cell + 中央空状态标签，保留现有 modal dismiss 流程，同时支持左滑删除与点按恢复后立即关闭页面。

- preset 页沿用导航栏 modal 结构：左侧 `Save Current` 触发命名保存，右侧 `Done` 负责关闭；重名冲突继续使用 `savePreset(name:) -> Bool` 的返回值决定是否弹错误提示，而不扩展 VM/archivist 接口。

- T8: 保持 renderCSV/renderChromaticSnapshot 原样，仅通过 presentShareSheet(metrics: CeladonMetrics?) 的内部 guard 和空 items 保护防止无结果分享。

- T9: `ComparisonScreen` 保持单一控制器实现两种模式，不新增路由层；通过可选构造参数 `init(baselineRecord:comparisonRecord:)` 决定是“直接结果”还是“先选后比”。
- T9: `HistoryRecord.MetricsSummary` 新增 `evValue`，并在 `CarmineArchivist.preserveHistory` 写入 `metrics.expectancyValue`，用于修复对比场景下 EV 与 RTP 语义耦合问题。

- T10: 保留首次 viewDidAppear 自动触发 commenceSimulation 的逻辑，但将 refreshPanels 移到 if 外层，确保每次 appear 都刷新 metrics/history 派生 UI。
