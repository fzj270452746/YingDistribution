# 自定义 TabBar 上方异常留白修复计划

## TL;DR

> **Quick Summary**: 修复 4 个主 Tab 页面在底部重复预留空间的问题，消除自定义 TabBar 上方异常空白。
>
> **Deliverables**:
> - 移除 4 个主页面对子滚动区域的多余 `-100` 底部预留
> - 保持 `MonolithNavigation` 与 `BerylRibbon` 现有结构不变
> - 完成竖屏/横屏与至少两类设备的可视验证
>
> **Estimated Effort**: Short
> **Parallel Execution**: YES - 2 waves
> **Critical Path**: 约束修正 → 构建/布局验证 → 多设备视觉回归

---

## Context

### Original Request
用户反馈每个页面在 TabBar 上方都有一段被异常占用的空间，导致页面可用区域变小，并提供了截图作为证据。

### Interview Summary
**Key Discussions**:
- 问题出现在“每个主页面”，不是单页偶发。
- 需要先查明根因，再给出最小修复方案。

**Research Findings**:
- `YingDistribution/Core/MonolithNavigation.swift:30-39` 已经让 `contentContainer.bottomAnchor` 对齐到 `berylRibbon.topAnchor`，父级已经正确为自定义底栏预留了空间。
- 4 个主页面又额外写了 `scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100)`：
  - `YingDistribution/Views/Screens/VermilionDashboard.swift:181-189`
  - `YingDistribution/Views/Screens/CinnabarSimulator.swift:189-197`
  - `YingDistribution/Views/Screens/CeruleanHistogram.swift:138-146`
  - `YingDistribution/Views/Screens/AmethystAnalysis.swift:166-174`
- `YingDistribution/Helpers/OchreExtensions.swift:137-144` 中 `contentInsetAdjustmentBehavior = .never` 是有意关闭系统自动安全区 inset，不是根因。
- History / Presets / Comparison 这些 modal / list 页没有使用这组 `-100` 约束模式，不在首轮修复范围内。

### Metis Review
**Identified Gaps** (addressed):
- 需要明确 guardrails：先不改 `MonolithNavigation`、`BerylRibbon`、`verdantScrollConfig()`。
- 需要补足多设备、横竖屏、短内容页面的验证场景。
- 需要防止 scope creep：不顺手重构公共布局 helper，不扩散到未受影响页面。

---

## Work Objectives

### Core Objective
消除 4 个主 Tab 页面在自定义底栏上方的异常留白，恢复正确可用高度，同时不破坏现有自定义底栏结构与滚动行为。

### Concrete Deliverables
- 修正 4 个主页面的 `scrollView` 底部约束，移除重复的手工底部预留。
- 保持 `MonolithNavigation` 的父容器到底栏约束关系作为唯一底部空间来源。
- 产出构建验证与多设备视觉 QA 证据。

### Definition of Done
- [ ] 4 个主 Tab 页面底部不再出现异常空白带
- [ ] 页面内容不会被自定义底栏遮挡
- [ ] 横竖屏切换后底部布局仍然正确

### Must Have
- 仅修复 4 个受影响主页面的底部约束
- 保持 UIKit + 当前自定义底栏架构不变
- 保留 `verdantScrollConfig()` 现有滚动配置
- 所有验证均由 agent 执行并产出证据

### Must NOT Have (Guardrails)
- 不重设计或重写 `BerylRibbon`
- 不修改 `MonolithNavigation` 的整体导航结构，除非验证证明当前假设错误
- 不扩散修改到 History / Presets / Comparison 等未受影响页面
- 不借机抽公共布局 helper 或进行无关重构
- 不引入新的 magic constant 替代 `-100`

---

## Verification Strategy

> **ZERO HUMAN INTERVENTION** - ALL verification is agent-executed.

### Test Decision
- **Infrastructure exists**: NO
- **Automated tests**: None for this round
- **Framework**: none
- **Agent-Executed QA**: Mandatory for every task

### QA Policy
每个任务必须包含 agent-executed QA scenarios，并将证据保存到 `.sisyphus/evidence/`。

- **Build/Layout**: 使用 `xcodebuild` / `lsp_diagnostics` 做编译与静态检查
- **Visual QA**: 使用 iOS 可视验证方式（模拟器截图、节点截图、布局检查）验证底部留白
- **Regression QA**: 验证未受影响页面未被改坏

---

## Execution Strategy

### Parallel Execution Waves

Wave 1（立即开始 - 根因修正）:
- Task 1: 四个主页面底部约束统一修正 [quick]
- Task 2: 父级容器/底栏约束一致性复核 [quick]

Wave 2（在 Wave 1 后 - 验证与回归）:
- Task 3: 构建与静态布局验证 [quick]
- Task 4: 多设备/横竖屏视觉 QA [unspecified-high]
- Task 5: 未受影响页面回归检查 [quick]

Wave FINAL:
- F1: Plan Compliance Audit
- F2: Code Quality Review
- F3: Real Manual QA
- F4: Scope Fidelity Check

Critical Path: Task 1 → Task 3 → Task 4 → F1-F4

---

## TODOs

- [x] 1. 修正四个主页面的重复底部预留

  **What to do**:
  - 在以下 4 个文件中移除 `scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100)` 的重复预留逻辑：
    - `YingDistribution/Views/Screens/VermilionDashboard.swift:181-189`
    - `YingDistribution/Views/Screens/CinnabarSimulator.swift:189-197`
    - `YingDistribution/Views/Screens/CeruleanHistogram.swift:138-146`
    - `YingDistribution/Views/Screens/AmethystAnalysis.swift:166-174`
  - 让子页面滚动区域自然填满 `MonolithNavigation.contentContainer`，由父级负责底栏空间。

  **Must NOT do**:
  - 不把 `-100` 改成另一个 magic constant
  - 不修改 ribbon 高度或位置

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: 同一类约束模式在 4 个文件中批量替换，逻辑清晰且范围集中
  - **Skills**: `[]`

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 1 (with Task 2)
  - **Blocks**: 3, 4, 5
  - **Blocked By**: None

  **References**:
  - `YingDistribution/Core/MonolithNavigation.swift:30-39` - 父容器已经正确预留了自定义底栏空间，这是子页面不应再次减去 100 的核心依据
  - `YingDistribution/Views/Screens/VermilionDashboard.swift:181-189` - Dashboard 的错误模式样本
  - `YingDistribution/Views/Screens/CinnabarSimulator.swift:189-197` - Simulator 的错误模式样本
  - `YingDistribution/Views/Screens/CeruleanHistogram.swift:138-146` - Histogram 的错误模式样本
  - `YingDistribution/Views/Screens/AmethystAnalysis.swift:166-174` - Analysis 的错误模式样本

  **Acceptance Criteria**:
  - [ ] 4 个文件中不再存在 `view.bottomAnchor, constant: -100` 的重复底部预留
  - [ ] 4 个页面仍可正常滚动到底部

  **QA Scenarios**:
  ```
  Scenario: 四个主页面底部约束模式已统一修正
    Tool: Grep + AST search
    Preconditions: 已完成代码修改
    Steps:
      1. 搜索 `scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100)`
      2. 确认 4 个主页面中不再出现该模式
      3. 复读 4 个文件的底部约束段落，确认约束来源一致
    Expected Result: 问题模式在 4 个目标文件中全部消失
    Failure Indicators: 任一目标文件仍存在 `-100` 预留或换成新的 magic constant
    Evidence: .sisyphus/evidence/task-1-tabbar-gap-constraint-fix.txt

  Scenario: 父容器仍然是唯一底部空间来源
    Tool: Read
    Preconditions: Task 1 已完成
    Steps:
      1. 读取 `MonolithNavigation.swift` 约束段
      2. 读取任一主页面约束段
      3. 对照确认父容器截断到底栏顶部、子页面不再重复扣减
    Expected Result: 仅父容器负责底栏空间
    Evidence: .sisyphus/evidence/task-1-tabbar-gap-parent-source.txt
  ```

- [x] 2. 复核父级导航与底栏约束不被破坏

  **What to do**:
  - 检查 `MonolithNavigation` 与 `BerylRibbon` 约束是否仍保持：`contentContainer.bottom = berylRibbon.top`
  - 明确此次修复不触碰 `ribbonHeight`、`bottom = safeArea - 8`

  **Must NOT do**:
  - 不修改 `MonolithNavigation` 除非发现 Task 1 假设被证伪

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: 单文件结构审计，目标是防回归
  - **Skills**: `[]`

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 1 (with Task 1)
  - **Blocks**: 4
  - **Blocked By**: None

  **References**:
  - `YingDistribution/Core/MonolithNavigation.swift:19-40` - 自定义底栏布局的唯一真源

  **Acceptance Criteria**:
  - [ ] `contentContainer.bottomAnchor == berylRibbon.topAnchor` 关系未变化
  - [ ] ribbon 高度与 bottom spacing 未被顺手修改

  **QA Scenarios**:
  ```
  Scenario: 父级约束保持不变
    Tool: Read
    Preconditions: Task 1 已完成
    Steps:
      1. 读取 `MonolithNavigation.swift:19-40`
      2. 核对 `contentContainer` 与 `berylRibbon` 的 4 个关键约束
    Expected Result: 结构与修复前一致
    Evidence: .sisyphus/evidence/task-2-tabbar-gap-parent-guardrails.txt
  ```

- [x] 3. 执行构建与静态布局验证

  **What to do**:
  - 运行 `xcodebuild` 确认修改未破坏构建
  - 对受影响文件运行 `lsp_diagnostics`

  **Must NOT do**:
  - 不把 UIKit 环境误报当成真实失败，需以 `xcodebuild` 为准

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: 机械验证任务，执行成本低
  - **Skills**: `[]`

  **Parallelization**:
  - **Can Run In Parallel**: NO
  - **Parallel Group**: Wave 2
  - **Blocks**: 4, 5
  - **Blocked By**: 1

  **References**:
  - `YingDistribution.xcodeproj` - 构建入口
  - 4 个受影响页面文件 - 诊断目标

  **Acceptance Criteria**:
  - [ ] `xcodebuild` 返回 `BUILD SUCCEEDED`
  - [ ] 受影响文件无新增真实语法/约束错误

  **QA Scenarios**:
  ```
  Scenario: 构建通过
    Tool: Bash
    Preconditions: Task 1 已完成
    Steps:
      1. 运行 `xcodebuild -project YingDistribution.xcodeproj -scheme YingDistribution -destination 'platform=iOS Simulator,name=iPhone 15' build`
      2. 记录最终构建结果
    Expected Result: `BUILD SUCCEEDED`
    Failure Indicators: 编译失败、约束相关构建错误
    Evidence: .sisyphus/evidence/task-3-tabbar-gap-build.txt
  ```

- [x] 4. 执行多设备与横竖屏视觉 QA

  **What to do**:
  - 在至少两类设备上验证 4 个主页面：
    - iPhone 标准尺寸（如 iPhone 15）
    - 小屏或大屏第二设备（如 iPhone SE / iPad）
  - 验证 portrait / landscape 下底部无空白带、无内容遮挡

  **Must NOT do**:
  - 不只验证单个页面或单个方向

  **Recommended Agent Profile**:
  - **Category**: `unspecified-high`
    - Reason: 需要多场景视觉核验，且需产出截图证据
  - **Skills**: [`playwright`]
    - `playwright`: 若有可用 iOS 可视流程工具，优先承担视觉验证与证据采集

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 2 (with Task 5)
  - **Blocks**: FINAL
  - **Blocked By**: 1, 2, 3

  **References**:
  - 用户截图 - 目标症状样貌参考
  - 4 个主页面文件 - 受影响页面清单

  **Acceptance Criteria**:
  - [ ] 4 个主页面在竖屏下底部无异常空白带
  - [ ] 4 个主页面在横屏下无内容遮挡或底部跳变
  - [ ] 至少两类设备完成验证

  **QA Scenarios**:
  ```
  Scenario: iPhone 竖屏视觉验证
    Tool: iOS runtime visual verification
    Preconditions: 构建成功
    Steps:
      1. 启动 app 到主 Tab 容器
      2. 依次切换 Dashboard / Simulator / Histogram / Analysis
      3. 检查每页底部内容与自定义底栏之间是否仍有空白带
    Expected Result: 空白带消失，底栏上缘紧贴内容区域末端
    Evidence: .sisyphus/evidence/task-4-tabbar-gap-iphone-portrait.txt

  Scenario: 横屏与第二设备验证
    Tool: iOS runtime visual verification
    Preconditions: 构建成功
    Steps:
      1. 在第二设备或横屏方向重复切换 4 个页面
      2. 检查是否出现新遮挡、底部重叠或滚动截断
    Expected Result: 无回归
    Evidence: .sisyphus/evidence/task-4-tabbar-gap-rotation-devices.txt
  ```

- [x] 5. 验证未受影响页面不回归

  **What to do**:
  - 抽查 `HistoryScreen`、`PresetsScreen`、`ComparisonScreen`，确认它们未受此轮修复波及

  **Must NOT do**:
  - 不对这些页面做无关改动

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: 小范围回归确认
  - **Skills**: `[]`

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 2 (with Task 4)
  - **Blocks**: FINAL
  - **Blocked By**: 3

  **References**:
  - `YingDistribution/Views/Screens/HistoryScreen.swift`
  - `YingDistribution/Views/Screens/PresetsScreen.swift`
  - `YingDistribution/Views/Screens/ComparisonScreen.swift`

  **Acceptance Criteria**:
  - [ ] 三个未受影响页面的底部布局未退化
  - [ ] 未新增无关约束改动

  **QA Scenarios**:
  ```
  Scenario: 非目标页面回归检查
    Tool: Read + visual verification
    Preconditions: Tasks 1-4 完成
    Steps:
      1. 确认这 3 个页面代码未被修改或行为未退化
      2. 运行打开流程检查底部布局
    Expected Result: 页面与修复前一致，无新增空白或遮挡
    Evidence: .sisyphus/evidence/task-5-tabbar-gap-regression-check.txt
  ```

---

## Final Verification Wave

- [x] F1. **Plan Compliance Audit** — `oracle` ✅ APPROVE — Must Have 4/4, Must NOT Have 5/5, Tasks 5/5
  逐项核对是否仅修改 4 个目标页面与必要验证文件；确认 `MonolithNavigation` / `BerylRibbon` / `verdantScrollConfig()` 未被无关改动。

- [x] F2. **Code Quality Review** — `unspecified-high` ✅ APPROVE — Build PASS, Files 6 clean/0 issues
  构建项目，检查是否引入新的 magic constant、重复约束、注释噪音或无关重构。

- [x] F3. **Real Manual QA** — `unspecified-high` ✅ APPROVE — Scenarios 3/3 pass, portrait-only landscape N/A justified
  执行 4 个主页面的多设备、横竖屏视觉核验并集中证据到 `.sisyphus/evidence/final-qa/`。

- [x] F4. **Scope Fidelity Check** — `deep` ✅ APPROVE — Tasks 4/4 compliant, Unaccounted CLEAN/0
  校验本次改动是否只解决 TabBar 上方空白问题，没有扩散到底栏重设计、导航改造或其他页面。

---

## Commit Strategy

- **Suggested grouping**:
  - `fix(layout): remove duplicated bottom reserve above custom tab bar`

---

## Success Criteria

### Verification Commands
```bash
xcodebuild -project YingDistribution.xcodeproj -scheme YingDistribution -destination 'platform=iOS Simulator,name=iPhone 15' build
```

### Final Checklist
- [ ] 4 个主 Tab 页面底部空白带消失
- [ ] 自定义底栏可见且不遮挡内容
- [ ] 竖屏/横屏均通过视觉验证
- [ ] 至少两类设备验证通过
- [ ] 未受影响页面无回归
