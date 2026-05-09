# 决策记录

## Task 2 — 父级导航 guardrail 审计 (PASS)
- 审计 `YingDistribution/Core/MonolithNavigation.swift:19-41`，三个关键不变量全部保持原样：
  - L34 `contentContainer.bottomAnchor == berylRibbon.topAnchor`
  - L38 `berylRibbon.bottom == safeAreaLayoutGuide.bottom - 8`
  - L28+L39 `ribbonHeight = 70`
- 父容器仍是底栏空间的唯一来源，没有发现父级本身产生异常空白的证据。
- 决策：Task 1 的修复方向（移除子页面 `-100` 重复预留）保持不变；明确禁止顺手改动 `MonolithNavigation` / `BerylRibbon` / ribbon 高度 / bottom spacing。
- Evidence: `.sisyphus/evidence/task-2-tabbar-gap-parent-guardrails.txt`

## Task 5 Decision: 未受影响页面回归抽查

- 抽查 HistoryScreen / PresetsScreen / ComparisonScreen 三页面，确认其底部布局未使用 `view.bottomAnchor, constant: -100` 写死偏移模式，故不在本轮修复范围内。
- HistoryScreen / PresetsScreen 采用 "tableView 直贴 view 底 + contentInset 处理边距" 范式；ComparisonScreen 的 compareButton 已正确锚定 `view.safeAreaLayoutGuide.bottomAnchor`。
- 学到的通用范式：列表/滚动容器优先使用 `view.bottomAnchor` 让系统 safeAreaInsets 自然覆盖 tabBar；交互按钮则使用 `safeAreaLayoutGuide.bottomAnchor`。**禁止**用写死的 `-100` 来"假装"避开 tabBar。
- 结论：无回归风险。
