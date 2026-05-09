## 2026-05-07
- `VermilionDashboardVM` 现在在模拟完成后串联 latest 持久化、history 写入、history 状态刷新与 insights 生成，适合作为 dashboard 的统一聚合入口。
- 从历史恢复时，可直接用 `HistoryRecord.ConfigSummary` 重建 `CobaltConfig`，再复用 `commenceSimulation(with:)` 保持行为一致。

- `HistoryScreen` 通过 `viewWillAppear` + `VermilionDashboardVM.shared.history` 直接刷新列表，无需额外订阅即可拿到最新本地历史状态。

- `PresetsScreen` 可直接复用 history 页的 `UITableView` 卡片样式，并在 `viewWillAppear` 中调用 `viewModel.loadPresets()` 来确保 modal 每次打开都与本地 UserDefaults 同步。

- T8: IndigoExporter 新增 PDF 导出与 exportCSV/exportPDF 辅助方法；分享前统一清理同名临时 CSV/PDF/PNG 文件，避免 temporaryDirectory 累积旧文件。

- T9: ComparisonScreen 采用双入口同屏切换（选择态 + 结果态）：无参进入先选 baseline/comparison，两条都选中后再展示 Compare 按钮；有参进入直接渲染对比结果。
- T9: 对比结果统一用 `ComparisonSnapshot` 驱动 4 个核心指标行（RTP/Hit Rate/EV/Spin/Max Win），delta 颜色映射固定为 正=verdantTeal、负=crimsonFlare、零=silverHaze。

- T10: Dashboard refreshPanels 需以 hasMetrics/history 实时驱动卡片占位、tier 空状态文案与 Export/Compare 按钮禁用态，避免页面回到前台时状态过期。

- T11: 导出入口的失败反馈不能静默 return；`IndigoExporter.presentShareSheet` 需要对 `metrics == nil` 与 `items.isEmpty` 两个分支统一弹出失败提示，才能满足边界异常回归可观测性要求。
- Comparison 历史快照新增可选 Codable 字段时，需手写 init(from:) / encode(to:) 并给旧数据提供 decodeIfPresent 默认值，避免历史归档升级崩溃。
- Tier 级别历史快照应按 CinnabarTier.allCases 固定顺序落盘，再在对比页按 tierName 建映射做 delta，才能同时兼顾顺序稳定与旧记录缺省兼容。
- History/Presets 列表里的 NumberFormatter 需要提升为 file-private 共享实例，避免 cell 渲染路径重复创建 formatter。
## 2026-05-07 F3 重审
- Final QA 需严格对齐计划 Assumptions：preset 首轮范围仅含保存/加载/删除/重名保护，不能因缺 rename 判失败。
- ComparisonScreen 当前已补齐 Tier Breakdown 证据，结果态不仅覆盖 4 张核心指标卡，也覆盖 tier delta 区块。
