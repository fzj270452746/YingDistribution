# YingDistribution 产品完整度增强计划

## TL;DR

> **Quick Summary**: 为当前 iOS 应用补齐 5 项最值得优先建设的产品能力：历史记录、方案对比、PDF/CSV 导出、参数模板、insight 解读卡片，使其从单次模拟器升级为完整的实验分析工具。
>
> **Deliverables**:
> - 本地实验历史与恢复能力
> - 多实验对比视图与差异展示
> - CSV / PDF 导出与系统分享能力
> - 本地 preset 保存/加载/删除能力
> - 自动 insight 生成与 dashboard 呈现
>
> **Estimated Effort**: Medium-Large
> **Parallel Execution**: YES - 3 waves + final verification
> **Critical Path**: 数据模型/归档扩展 → VM 聚合层 → 历史/预设/对比/insight/UI 导出整合

---

## Context

### Original Request
读取当前项目并分析是否有 App Store 4.3 风险；如有，给出最值得优先补强的功能。用户确认优先围绕以下 5 项做增强：历史记录 / 保存实验、多方案对比、导出 PDF / CSV、参数模板 / preset、insight 解读卡片。

### Interview Summary
**Key Discussions**:
- 用户确认这 5 项功能进入同一份执行计划
- 功能强度选择：完整版本，而非 MVP
- 数据策略：仅本地，不做云同步
- 自动化测试：本轮先不要求自动化测试，仅要求可执行 QA 验证
- 明确排除：本轮不把“去博彩化命名/文案/术语重构”纳入同一计划

**Research Findings**:
- 当前状态管理集中在 `YingDistribution/ViewModels/VermilionDashboardVM.swift`，使用 `@Published` 输出 dashboard 状态
- 当前持久化集中在 `YingDistribution/Services/CarmineArchivist.swift`，使用 UserDefaults + JSON envelope，适合扩展更多本地实体
- 当前已经有 `YingDistribution/Services/IndigoExporter.swift`，已具备 CSV + 图片分享的初步实现，可扩展为更完整的导出服务
- 当前导航容器为 `YingDistribution/Core/MonolithNavigation.swift`，适合加入新 screen 或 modal 入口
- 当前 `YingDistribution/Views/Screens/VermilionDashboard.swift` 是产品首页，适合承接入口、概览、insight 与导出操作
- 当前项目无 test target、无 UI test、无 CI，因此本轮以 agent-executed QA 为主

### Metis Review
**Identified Gaps** (addressed):
- 历史记录需明确留存边界：计划中限制为本地列表、基础删除、无高级检索
- 预设功能易膨胀为共享/导入系统：计划中明确仅本地 preset 管理
- 导出功能易膨胀为自动归档/批量导出：计划中限制为手动导出当前结果/对比结果
- 对比功能需限制复杂度：计划中明确首轮仅支持 2 个实验并排对比
- insight 功能需避免配置化规则编辑器：计划中明确为只读、内建规则生成
- 缺少边界异常策略：计划中加入空状态、坏数据恢复、命名冲突、无结果导出的 QA 场景

---

## Work Objectives

### Core Objective
将当前单次模拟与指标展示应用升级为具备“保存、回看、对比、导出、解释”闭环的完整分析工具，显著提升产品完整度与 App 审核感知价值。

### Concrete Deliverables
- 扩展本地归档结构，支持实验记录、对比实体、preset 实体
- 在 dashboard 之上增加历史记录、对比、preset 管理、insight 呈现与导出入口
- 保持 UIKit + MVVM + UserDefaults/JSON 现有架构，不引入新存储引擎

### Definition of Done
- [ ] 用户可运行一次模拟并在 App 内看到新建历史记录
- [ ] 用户可从历史中恢复实验并选择两个实验做对比
- [ ] 用户可导出当前结果为 CSV / PDF 并拉起系统分享
- [ ] 用户可保存、重命名感知清晰的本地 preset，并再次加载使用
- [ ] 首页可基于结果展示自动生成的 insight 卡片

### Must Have
- 五项功能全部纳入一个计划并具备可执行落地点
- 所有新增持久化均为本地存储
- 所有新增界面遵循现有视觉语言与 UIKit 架构
- 所有任务都包含 agent-executed QA scenarios

### Must NOT Have (Guardrails)
- 不做云同步 / iCloud / 账号系统
- 不做术语去博彩化重构
- 不引入 Core Data / Realm / SQLite / 第三方数据库
- 不引入 SwiftUI 重写或大规模架构迁移
- 不扩展为团队协作、批量导出、自动导出、规则编辑器

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

- **Frontend/UI**: 使用 Playwright 或可替代的 iOS 可视验证方式（如启动模拟器 + 截图证据）执行界面验证
- **Build/Runtime**: 使用 `xcodebuild` / 运行模拟器进行构建与基础流程验证
- **Export/File**: 使用命令行检查临时目录与导出文件存在性、文件大小、扩展名正确性
- **Persistence**: 通过重新启动应用 / 重新打开页面验证 UserDefaults 恢复行为

### Assumptions & Constraints
- 历史记录首轮仅支持基础列表与删除，不做搜索/过滤
- 历史记录默认上限：100 条；超过上限时自动淘汰最旧记录
- 对比首轮仅支持 2 个实验同时对比
- 对比页首轮固定展示：RTP、Hit Rate、EV / Spin、Max Win 四项核心指标 + tier breakdown 差异；bucket 仅展示摘要，不做全量并排表
- preset 首轮仅支持本地保存、加载、删除、重名保护
- preset 重名策略：默认阻止直接保存并提示用户重命名；本轮不做静默覆盖、不做自动追加 `(2)`
- insight 首轮为只读自动生成，不支持用户编辑
- insight 首轮内建规则集目标：至少 6 条固定规则，覆盖高/低 RTP、高/低 Hit Rate、高波动、峰值异常、tier 集中度、空结果提示
- 导出首轮以当前结果与当前对比结果的手动导出为主
- 导出文件写入 `FileManager.default.temporaryDirectory`，每次导出前先清理同名旧文件，避免临时文件无上限累积
- `VermilionDashboardVM` 若状态负担过大，允许在不改变 MVVM 大框架前提下拆出轻量 coordinator/helper，但不得演变为新架构迁移

---

## Execution Strategy

### Parallel Execution Waves

Wave 1 (Start Immediately - foundation + data contracts):
├── Task 1: 扩展本地归档模型与 UserDefaults key 体系 [quick]
├── Task 2: 定义 history / preset / comparison / insight 数据模型 [quick]
├── Task 3: 扩展 Dashboard VM 聚合状态与共享操作入口 [quick]
└── Task 4: 规划新页面入口与导航挂载策略 [quick]

Wave 2 (After Wave 1 - feature modules in parallel):
├── Task 5: 历史记录列表、恢复、删除流程 [unspecified-high]
├── Task 6: preset 保存、加载、删除、冲突处理 [unspecified-high]
├── Task 7: insight 规则生成器与 dashboard 卡片区 [quick]
└── Task 8: 导出服务增强（CSV/PDF/分享） [unspecified-high]

Wave 3 (After Wave 2 - synthesis + comparison):
├── Task 9: 双实验对比视图与差异指标展示 [deep]
├── Task 10: Dashboard 首页总入口整合与空状态完善 [unspecified-high]
└── Task 11: 持久化恢复、边界异常、证据采集收口 [deep]

Wave FINAL (After ALL tasks — 4 parallel reviews):
├── Task F1: Plan compliance audit (oracle)
├── Task F2: Code quality review (unspecified-high)
├── Task F3: Real manual QA (unspecified-high)
└── Task F4: Scope fidelity check (deep)

Critical Path: Task 1 → Task 3 → Task 5/6/7/8 → Task 9 → Task 10 → Task 11 → F1-F4
Parallel Speedup: ~55% faster than sequential
Max Concurrent: 4

### Dependency Matrix

- **1**: None → 3, 5, 6, 8, 11
- **2**: None → 3, 5, 6, 7, 9
- **3**: 1, 2 → 5, 6, 7, 8, 10
- **4**: None → 5, 6, 9, 10
- **5**: 1, 2, 3, 4 → 9, 10, 11
- **6**: 1, 2, 3, 4 → 10, 11
- **7**: 2, 3 → 10, 11
- **8**: 1, 3 → 10, 11
- **9**: 2, 4, 5 → 10, 11
- **10**: 3, 4, 5, 6, 7, 8, 9 → 11
- **11**: 1, 5, 6, 7, 8, 9, 10 → F1, F2, F3, F4

### Agent Dispatch Summary

- **Wave 1**: T1-T4 → `quick`
- **Wave 2**: T5 → `unspecified-high`, T6 → `unspecified-high`, T7 → `quick`, T8 → `unspecified-high`
- **Wave 3**: T9 → `deep`, T10 → `unspecified-high`, T11 → `deep`
- **FINAL**: F1 → `oracle`, F2 → `unspecified-high`, F3 → `unspecified-high`, F4 → `deep`

---

## TODOs

- [x] 1. 扩展本地归档模型与 UserDefaults key 体系

  **What to do**:
  - 在 `YingDistribution/Services/CarmineArchivist.swift` 上扩展现有 envelope 模式，新增实验历史、preset、本地对比快照的 key 与序列化封装
  - 统一命名策略、时间戳策略、基础上限策略（如历史记录数量上限）与坏数据兜底策略
  - 明确 key 命名版本化规则（如 `ying_history_v1`、`ying_presets_v1`），为后续 schema 演进预留安全升级空间
  - 保持当前 `preserveLatest` / `retrieveLatest` 兼容，不破坏现有归档能力

  **Must NOT do**:
  - 不改用 Core Data / SQLite / Realm
  - 不引入云同步或文件数据库

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: 该任务是单模块内的本地数据结构扩展，变更集中且依赖明确
  - **Skills**: `[]`
  - **Skills Evaluated but Omitted**:
    - `playwright`: 非浏览器交互任务

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 1 (with Tasks 2, 4)
  - **Blocks**: 3, 5, 6, 8, 11
  - **Blocked By**: None

  **References**:
  - `YingDistribution/Services/CarmineArchivist.swift:3-35` - 当前归档服务入口与 key 管理方式，需要在同一风格下扩展
  - `YingDistribution/Services/CarmineArchivist.swift:37-115` - 现有 envelope / unwrap 模式，是 history/preset/comparison 的直接参考模板
  - `YingDistribution/Models/CeladonMetrics.swift:44-64` - 当前 `CobaltConfig` 结构决定 preset/history 需要保存哪些配置字段

  **Acceptance Criteria**:
  - [ ] 新增的 history / preset / comparison 本地实体均可被 encode / decode
  - [ ] 旧的 latest metrics / config 读取行为不退化
  - [ ] 坏数据或缺失数据场景下，归档读取返回安全空结果而非崩溃
  - [ ] 历史记录超过 100 条时，自动裁剪最旧项且不影响最新数据读取
  - [ ] 新增 key 均采用版本化命名，避免后续结构升级时发生歧义

  **QA Scenarios**:
  ```
  Scenario: 历史与 preset 数据可持久化并恢复
    Tool: Bash (xcodebuild) + app runtime verification
    Preconditions: App 可构建启动
    Steps:
      1. 构建并启动 app，执行一次模拟并保存 1 条历史与 1 个 preset
      2. 关闭并重新启动 app
      3. 打开相关页面，确认历史和 preset 仍然存在
    Expected Result: 数据成功恢复，列表非空，应用无崩溃
    Failure Indicators: 启动崩溃、列表为空、读取失败
    Evidence: .sisyphus/evidence/task-1-persistence-reload.txt

  Scenario: 坏数据回退不崩溃
    Tool: Bash
    Preconditions: 可定位 app 使用的 UserDefaults 容器
    Steps:
      1. 将某个归档 key 写入无效 JSON / 不完整结构
      2. 启动 app 并进入历史/preset 相关页面
      3. 观察 app 是否安全回退为空状态
    Expected Result: 页面可正常打开，坏数据被忽略
    Evidence: .sisyphus/evidence/task-1-corrupt-data.txt
  ```

  **Commit**: NO

- [x] 2. 定义 history / preset / comparison / insight 数据模型

  **What to do**:
  - 新增清晰的模型层结构，承载实验摘要、preset 元数据、对比快照与 insight 展示信息
  - 确保模型字段足以支持“列表展示 + 恢复 + 对比 + 导出 + insight 展示”但不过度膨胀
  - 明确命名、时间、摘要、关联 metrics/config 的映射方式

  **Must NOT do**:
  - 不把模型设计成未来云同步或多人协作协议
  - 不把 insight 做成可编辑规则引擎 schema

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: 主要是模型定义与契约清晰化，适合快速高确定性工作
  - **Skills**: `[]`
  - **Skills Evaluated but Omitted**:
    - `review-work`: 这是最终验证阶段使用，不适合单任务前置

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 1 (with Tasks 1, 4)
  - **Blocks**: 3, 5, 6, 7, 9
  - **Blocked By**: None

  **References**:
  - `YingDistribution/Models/CeladonMetrics.swift:3-42` - 现有 metrics 结构决定 history/comparison 如何关联业务结果
  - `YingDistribution/Models/ZirconBucket.swift` - bucket 粒度数据对 comparison/export/insight 的字段需求有直接影响
  - `YingDistribution/ViewModels/VermilionDashboardVM.swift:8-38` - view model 已暴露哪些摘要值，可反推模型最小必要字段

  **Acceptance Criteria**:
  - [ ] history / preset / comparison / insight 模型职责边界明确
  - [ ] 模型字段可以覆盖列表、详情、对比、导出、洞察五类使用场景
  - [ ] 命名一致，无明显重复字段或跨层泄漏

  **QA Scenarios**:
  ```
  Scenario: 新模型可支持完整展示链路
    Tool: Bash (build) + code inspection
    Preconditions: 模型已接入编译目标
    Steps:
      1. 构建项目确保新增模型全部通过编译
      2. 运行一次模拟并保存实验
      3. 检查历史列表、对比页、insight 卡片是否都能从模型取到所需字段
    Expected Result: 各界面不需要临时拼字段补洞
    Failure Indicators: 编译失败、界面字段为空、需要硬编码兜底文本
    Evidence: .sisyphus/evidence/task-2-model-contract.txt

  Scenario: 空 metrics / 空摘要场景安全处理
    Tool: Bash + runtime verification
    Preconditions: 删除已有存档或首次启动
    Steps:
      1. 启动 app 于无历史数据状态
      2. 进入相关页面
      3. 检查模型驱动的 UI 是否展示空状态而非崩溃
    Expected Result: 空状态正常显示
    Evidence: .sisyphus/evidence/task-2-empty-state.txt
  ```

  **Commit**: NO

- [x] 3. 扩展 Dashboard VM 聚合状态与共享操作入口

  **What to do**:
  - 在 `YingDistribution/ViewModels/VermilionDashboardVM.swift` 中扩展共享状态：history、presets、selectedComparison、insights、导出触发入口
  - 在模拟完成后串联：保存 latest → 写入 history → 生成 insights → 刷新首页状态
  - 增加恢复历史、加载 preset、准备 comparison 数据、触发导出所需的协调方法
  - 若 `VermilionDashboardVM` 职责膨胀，允许抽出轻量 helper/coordinator 来承接非展示逻辑，但对外仍保持 VM 为统一 UI 入口

  **Must NOT do**:
  - 不把 VM 改造成全局 service locator
  - 不引入新的状态管理框架

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: 这是现有单一 VM 的集中扩展任务，依赖清晰但影响面大
  - **Skills**: `[]`
  - **Skills Evaluated but Omitted**:
    - `ultrabrain`: 不属于高复杂算法或体系级难题

  **Parallelization**:
  - **Can Run In Parallel**: NO
  - **Parallel Group**: Sequential in Wave 1
  - **Blocks**: 5, 6, 7, 8, 10
  - **Blocked By**: 1, 2

  **References**:
  - `YingDistribution/ViewModels/VermilionDashboardVM.swift:4-64` - 当前唯一共享 VM，需要在现有 API 风格上平滑扩展
  - `YingDistribution/Services/CarmineArchivist.swift:8-34` - VM 通过 archivist 完成本地读写，是 history/preset 入口的现有依赖模式
  - `YingDistribution/Views/Screens/VermilionDashboard.swift:33-42` - 首次出现时 restore / auto-run 逻辑，决定新增状态如何挂入初始化路径

  **Acceptance Criteria**:
  - [ ] 模拟完成后 history / latest / insights 同步更新
  - [ ] VM 暴露的公开接口足够支撑历史、preset、导出、对比页面调用
  - [ ] 新状态变化能驱动 dashboard 与新增页面刷新
  - [ ] VM 新增状态职责清晰，没有把文件生成、复杂规则细节、原始归档细节全部硬塞进单一类中

  **QA Scenarios**:
  ```
  Scenario: 一次模拟驱动完整状态链路
    Tool: Runtime verification
    Preconditions: App 已启动至 dashboard
    Steps:
      1. 从模拟页执行一次新模拟
      2. 返回 dashboard
      3. 验证最新 metrics、history 列表、insight 卡片都已更新
    Expected Result: 三类状态同步变化，无需重启 app
    Failure Indicators: 仅首页更新、history 未写入、insight 未刷新
    Evidence: .sisyphus/evidence/task-3-state-chain.txt

  Scenario: 加载 preset 后再次模拟生效
    Tool: Runtime verification
    Preconditions: 已存在至少 1 个 preset
    Steps:
      1. 在 preset 页面加载某个 preset
      2. 返回模拟页并直接运行
      3. 检查结果对应新配置摘要
    Expected Result: activeConfig 被正确替换并生效
    Evidence: .sisyphus/evidence/task-3-preset-load.txt
  ```

  **Commit**: NO

- [x] 4. 规划新页面入口与导航挂载策略

  **What to do**:
  - 明确历史、preset、对比三个能力的入口形式（新 page、push、modal）并统一交互
  - 在 `YingDistribution/Core/MonolithNavigation.swift` 或 dashboard 入口区中接入访问路径
  - 保证新入口不破坏现有 ribbon 页面切换逻辑

  **Must NOT do**:
  - 不重写导航容器
  - 不引入外部路由框架

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: 该任务主要是现有导航结构下的入口规划与挂载
  - **Skills**: `[]`
  - **Skills Evaluated but Omitted**:
    - `frontend-ui-ux`: 当前是 iOS UIKit 本地导航，不是 Web UI 工程任务

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 1 (with Tasks 1, 2)
  - **Blocks**: 5, 6, 9, 10
  - **Blocked By**: None

  **References**:
  - `YingDistribution/Core/MonolithNavigation.swift:3-86` - 当前多页面容器、ribbon 与 page 切换机制
  - `YingDistribution/Views/Screens/VermilionDashboard.swift:70-78` - header 区已有 action button，可作为新增入口风格参考
  - `YingDistribution/Views/Screens/VermilionDashboard.swift:232-235` - 现有页面跳转方式依赖 parent navigation controller，需要保持兼容

  **Acceptance Criteria**:
  - [ ] 新功能入口清晰且可从 dashboard 到达
  - [ ] ribbon 切换和新入口不会互相破坏
  - [ ] 新页面返回路径明确且一致

  **QA Scenarios**:
  ```
  Scenario: 从 dashboard 可到达所有新增功能入口
    Tool: Runtime verification
    Preconditions: App 启动至首页
    Steps:
      1. 点击历史、preset、对比、导出相关入口
      2. 确认对应页面/弹层均可打开
      3. 返回 dashboard 并再次切换原 ribbon 页面
    Expected Result: 导航流畅，无卡死、无页面残留
    Failure Indicators: 某入口无响应、返回失败、页面层级错误
    Evidence: .sisyphus/evidence/task-4-navigation.txt

  Scenario: 重复打开关闭新页面不导致异常
    Tool: Runtime verification
    Preconditions: 新页面已接入
    Steps:
      1. 连续多次打开和关闭新增页面
      2. 交叉切换 ribbon tab
      3. 观察布局和交互状态
    Expected Result: 不出现空白页、重复叠层、按钮失效
    Evidence: .sisyphus/evidence/task-4-repeat-open.txt
  ```

  **Commit**: NO

- [x] 5. 历史记录列表、恢复、删除流程

  **What to do**:
  - 新增历史记录 screen，展示实验时间、关键配置摘要、核心指标摘要
  - 支持从历史记录恢复到当前 VM / dashboard 使用状态
  - 支持单条删除与空状态展示；首轮不做搜索、排序过滤器以外的高级能力

  **Must NOT do**:
  - 不做批量选择、批量操作
  - 不做复杂筛选、标签、收藏体系

  **Recommended Agent Profile**:
  - **Category**: `unspecified-high`
    - Reason: 涉及新 screen + 持久化 + VM 恢复链路，属于中等复杂 UI 流程整合
  - **Skills**: `[]`
  - **Skills Evaluated but Omitted**:
    - `playwright`: 非 Web 场景

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 2 (with Tasks 6, 7, 8)
  - **Blocks**: 9, 10, 11
  - **Blocked By**: 1, 2, 3, 4

  **References**:
  - `YingDistribution/ViewModels/VermilionDashboardVM.swift:40-63` - 当前 latest restore 流程，可扩展成 history 恢复路径
  - `YingDistribution/Views/Screens/VermilionDashboard.swift:154-166` - dashboard 指标刷新方式，历史恢复后需驱动相同 UI 更新
  - `YingDistribution/Core/MonolithNavigation.swift:43-49` - 当前页面组织方式，决定历史页如何接入

  **Acceptance Criteria**:
  - [ ] 历史页可看到至少时间、配置、核心指标摘要
  - [ ] 点击某历史项可恢复并刷新 dashboard
  - [ ] 删除某历史项后列表即时更新
  - [ ] 无历史记录时展示明确空状态

  **QA Scenarios**:
  ```
  Scenario: 历史记录创建并可恢复
    Tool: Runtime verification
    Preconditions: App 启动，能够执行模拟
    Steps:
      1. 连续运行两次不同参数的模拟
      2. 打开历史记录页，确认出现两条不同记录
      3. 点击较早一条记录恢复
      4. 返回 dashboard，确认指标与该历史记录匹配
    Expected Result: 恢复成功，首页数据同步更新
    Failure Indicators: 历史记录缺失、恢复无效、首页数据未变化
    Evidence: .sisyphus/evidence/task-5-history-restore.txt

  Scenario: 删除历史记录与空状态
    Tool: Runtime verification
    Preconditions: 历史页至少有 1 条记录
    Steps:
      1. 删除全部历史记录
      2. 观察列表与空状态文案
      3. 返回再进入历史页确认状态保持
    Expected Result: 列表为空且显示空状态，重新进入仍为空
    Evidence: .sisyphus/evidence/task-5-history-empty.txt
  ```

  **Commit**: NO

- [x] 6. preset 保存、加载、删除、冲突处理

  **What to do**:
  - 新增 preset 管理 screen 或 modal，支持基于当前配置保存 preset
  - 支持加载 preset 到 `activeConfig`，并提供删除操作
  - 处理命名冲突：本轮规则固定为“阻止保存并提示用户重命名”，不做覆盖、不做自动重命名

  **Must NOT do**:
  - 不做 preset 导入/导出
  - 不做分组、共享、云同步

  **Recommended Agent Profile**:
  - **Category**: `unspecified-high`
    - Reason: 需要打通配置保存、命名校验、回填配置与 UI 管理流程
  - **Skills**: `[]`
  - **Skills Evaluated but Omitted**:
    - `writing`: 非文档任务

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 2 (with Tasks 5, 7, 8)
  - **Blocks**: 10, 11
  - **Blocked By**: 1, 2, 3, 4

  **References**:
  - `YingDistribution/Models/CeladonMetrics.swift:44-64` - `CobaltConfig` 是 preset 保存与恢复的核心对象
  - `YingDistribution/Services/CarmineArchivist.swift:14-34` - 现有 config 持久化入口可演变为 preset 管理能力
  - `YingDistribution/ViewModels/VermilionDashboardVM.swift:14, 40-43` - `activeConfig` 更新与模拟触发链路

  **Acceptance Criteria**:
  - [ ] 用户可基于当前配置保存 preset
  - [ ] 用户可加载 preset 并在下一次模拟中生效
  - [ ] 用户可删除 preset
  - [ ] 重名保存被阻止，并给出清晰重命名提示

  **QA Scenarios**:
  ```
  Scenario: 保存并加载 preset
    Tool: Runtime verification
    Preconditions: App 启动，存在可修改配置的模拟页
    Steps:
      1. 配置一组非默认参数并保存为 preset “A”
      2. 修改为另一组参数
      3. 加载 preset “A”
      4. 运行模拟并确认参数恢复为 preset “A”
    Expected Result: preset 保存与回填正确
    Failure Indicators: 参数未恢复、保存后列表缺失、加载无效
    Evidence: .sisyphus/evidence/task-6-preset-load.txt

  Scenario: preset 重名冲突处理
    Tool: Runtime verification
    Preconditions: 已存在名为 “A” 的 preset
    Steps:
      1. 再次尝试以 “A” 保存新 preset
      2. 观察冲突处理交互
      3. 确认最终结果与预定规则一致
    Expected Result: 保存被阻止，用户收到重命名提示，列表中不产生重复脏数据
    Evidence: .sisyphus/evidence/task-6-name-conflict.txt
  ```

  **Commit**: NO

- [x] 7. insight 规则生成器与 dashboard 卡片区

  **What to do**:
  - 新增 insight model 与生成逻辑，根据当前 metrics 自动给出 2-5 条可读结论
  - 在 dashboard 加入 insight 区块，支持无结果、少量结果、多条结果布局
  - insight 需聚焦解释当前结果，而不是新增复杂推荐系统
  - 建立固定规则集文件/模块，至少覆盖：高 RTP、低 RTP、高 Hit Rate、低 Hit Rate、高 Max Win、tier 过度集中、无结果提示等规则中的 6 条

  **Must NOT do**:
  - 不做用户可编辑规则
  - 不做联网推荐、AI 生成、远端配置

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: 规则驱动的本地解释与单页面卡片呈现，复杂度中低
  - **Skills**: `[]`
  - **Skills Evaluated but Omitted**:
    - `oracle`: 不需要高阶架构推理

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 2 (with Tasks 5, 6, 8)
  - **Blocks**: 10, 11
  - **Blocked By**: 2, 3

  **References**:
  - `YingDistribution/Views/Screens/VermilionDashboard.swift:16-25` - dashboard 当前指标区与 summary 区结构，适合插入 insight 区
  - `YingDistribution/ViewModels/VermilionDashboardVM.swift:16-38` - 已暴露 rtp/hit/ev/max 等摘要指标，可作为 insight 输入
  - `YingDistribution/Models/CeladonMetrics.swift:10-33` - 当前 metrics 计算属性可直接支撑 insight 判断条件

  **Acceptance Criteria**:
  - [ ] 有结果时可生成可读 insight 卡片
  - [ ] 无结果时 dashboard 不崩溃且给出合适占位/隐藏策略
  - [ ] insight 与当前 metrics 一致，不出现明显自相矛盾
  - [ ] insight 规则来源集中管理，不散落在多个 VC / VM 条件分支中

  **QA Scenarios**:
  ```
  Scenario: 生成 insight 并展示在 dashboard
    Tool: Runtime verification
    Preconditions: 已执行至少一次模拟
    Steps:
      1. 返回 dashboard
      2. 查看 insight 区块
      3. 核对至少 2 条 insight 与当前指标一致
    Expected Result: insight 卡片出现，内容与当前结果匹配
    Failure Indicators: 卡片为空、内容与指标矛盾、布局错乱
    Evidence: .sisyphus/evidence/task-7-insights.txt

  Scenario: 无 metrics 场景的 insight 安全退化
    Tool: Runtime verification
    Preconditions: 清空当前结果或首次启动前无存档
    Steps:
      1. 启动 app 于无结果状态
      2. 打开 dashboard
      3. 观察 insight 区处理方式
    Expected Result: 正常隐藏或展示空占位，无崩溃
    Evidence: .sisyphus/evidence/task-7-empty.txt
  ```

  **Commit**: NO

- [x] 8. 导出服务增强（CSV/PDF/分享）

  **What to do**:
  - 基于现有 `YingDistribution/Services/IndigoExporter.swift` 扩展导出能力，保留 CSV 并补足 PDF
  - 统一导出文件命名、临时目录写入、错误兜底与系统分享入口
  - 明确临时文件清理策略：生成新导出前先清理同名旧文件，避免重复堆积
  - 若已有 chart snapshot，可复用到 PDF 或分享附件中

  **Must NOT do**:
  - 不做后台批量导出
  - 不做远端上传、邮件发送自动化

  **Recommended Agent Profile**:
  - **Category**: `unspecified-high`
    - Reason: 涉及文件生成、分享 sheet、PDF/CSV 两种格式与异常处理
  - **Skills**: `[]`
  - **Skills Evaluated but Omitted**:
    - `git-master`: 与 git 操作无关

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 2 (with Tasks 5, 6, 7)
  - **Blocks**: 10, 11
  - **Blocked By**: 1, 3

  **References**:
  - `YingDistribution/Services/IndigoExporter.swift:3-85` - 已有 CSV、图像快照、分享逻辑，是增强导出最直接的基础
  - `YingDistribution/Views/Screens/VermilionDashboard.swift:11-25` - 首页可作为导出入口放置区域参考
  - `YingDistribution/Models/CeladonMetrics.swift:3-42` - 导出 summary 与 bucket/tier 数据的来源模型

  **Acceptance Criteria**:
  - [ ] 当前结果可导出为 CSV
  - [ ] 当前结果可导出为 PDF
  - [ ] 分享 sheet 可正确携带导出文件
  - [ ] 无结果时导出入口有禁用或错误提示策略
  - [ ] 重复导出不会在临时目录无限堆积同名垃圾文件

  **QA Scenarios**:
  ```
  Scenario: 成功导出 CSV 与 PDF
    Tool: Runtime verification + Bash
    Preconditions: App 内已有当前模拟结果
    Steps:
      1. 点击导出操作
      2. 生成 CSV 和 PDF 并拉起分享 sheet
      3. 在临时目录检查文件存在、扩展名正确、文件大小大于 0
    Expected Result: 两种文件均生成成功
    Failure Indicators: 仅生成一种、分享 sheet 不出现、文件为空
    Evidence: .sisyphus/evidence/task-8-export-files.txt

  Scenario: 无结果时导出保护
    Tool: Runtime verification
    Preconditions: 当前无 metrics
    Steps:
      1. 打开 dashboard
      2. 触发导出入口
      3. 观察交互反馈
    Expected Result: 导出被禁用或给出清晰错误提示，不崩溃
    Evidence: .sisyphus/evidence/task-8-no-data.txt
  ```

  **Commit**: NO

- [x] 9. 双实验对比视图与差异指标展示

  **What to do**:
  - 基于历史记录选择两个实验，构建 side-by-side comparison 视图
  - 固定首轮展示：RTP、Hit Rate、EV / Spin、Max Win 四项核心指标差异 + tier breakdown 差异
  - bucket 层只展示摘要或代表性差异，不做全量复杂并排表
  - 设计清晰的“基准 vs 对照”关系与 delta 表达，避免 UI 信息爆炸

  **Must NOT do**:
  - 不支持 3 个及以上实验同时对比
  - 不做复杂时间线分析或趋势分析器

  **Recommended Agent Profile**:
  - **Category**: `deep`
    - Reason: 该任务需要统筹历史数据、指标结构、视觉表达与认知负担控制，是本计划中最复杂的交互合成点
  - **Skills**: `[]`
  - **Skills Evaluated but Omitted**:
    - `ui-ux-pro-max`: 可选但非必须；本轮优先遵循现有 UIKit 视觉系统而非重新设计风格

  **Parallelization**:
  - **Can Run In Parallel**: NO
  - **Parallel Group**: Sequential in Wave 3
  - **Blocks**: 10, 11
  - **Blocked By**: 2, 4, 5

  **References**:
  - `YingDistribution/Models/CeladonMetrics.swift:3-42` - 对比页需要基于现有 metrics 结构提炼可对比维度
  - `YingDistribution/ViewModels/VermilionDashboardVM.swift:16-38` - 当前摘要指标是首批最值得做 delta 的字段
  - `YingDistribution/Views/Screens/VermilionDashboard.swift:154-166` - 当前 card 呈现方式可复用为对比页的视觉语法
  - `YingDistribution/Services/IndigoExporter.swift:5-20` - 现有导出数据列结构可反向提示哪些 comparison 字段值得展示

  **Acceptance Criteria**:
  - [ ] 可明确选择两个实验进行对比
  - [ ] 对比页展示四项核心摘要差异和 tier breakdown 差异
  - [ ] 用户能看出哪一个实验更高/更低，delta 表达清晰
  - [ ] 数据不足时给出明确提示，不允许进入坏状态

  **QA Scenarios**:
  ```
  Scenario: 两个实验成功进入对比页并展示差异
    Tool: Runtime verification
    Preconditions: 已有两条不同历史记录
    Steps:
      1. 在历史页选择两条记录进入对比
      2. 检查对比页是否展示两组核心指标与 delta
      3. 核对至少一项差异值与原始记录一致
    Expected Result: 对比信息完整且数值匹配
    Failure Indicators: 仅显示单边数据、delta 错误、页面崩溃
    Evidence: .sisyphus/evidence/task-9-compare.txt

  Scenario: 对比数量不足时阻止进入
    Tool: Runtime verification
    Preconditions: 历史记录存在但仅选择 0 或 1 条
    Steps:
      1. 尝试进入对比页
      2. 观察交互反馈
    Expected Result: 给出明确提示，不进入错误页面
    Evidence: .sisyphus/evidence/task-9-selection-guard.txt
  ```

  **Commit**: NO

- [x] 10. Dashboard 首页总入口整合与空状态完善

  **What to do**:
  - 将历史、preset、对比、导出、insight 以统一入口组织进 dashboard 或其邻接流程
  - 优化首页的信息层次：保留现有核心指标，同时避免新功能堆叠后界面过载
  - 为无历史、无 insight、无可对比项、无可导出结果等状态提供清晰空状态或禁用态

  **Must NOT do**:
  - 不把首页改造成复杂工作台或多级嵌套导航迷宫
  - 不移除现有核心指标展示

  **Recommended Agent Profile**:
  - **Category**: `unspecified-high`
    - Reason: 该任务是多个模块完成后的首页整合，需要兼顾信息层次、交互清晰度与现有页面稳定性
  - **Skills**: `[]`
  - **Skills Evaluated but Omitted**:
    - `frontend-ui-ux`: 非 Web UI

  **Parallelization**:
  - **Can Run In Parallel**: NO
  - **Parallel Group**: Sequential in Wave 3
  - **Blocks**: 11
  - **Blocked By**: 3, 4, 5, 6, 7, 8, 9

  **References**:
  - `YingDistribution/Views/Screens/VermilionDashboard.swift:45-110` - 当前首页布局骨架，新增入口与 insight 区必须在这个结构上增量演进
  - `YingDistribution/Views/Screens/VermilionDashboard.swift:154-219` - 当前 summary/tier 呈现风格，是首页整合时保持一致性的关键
  - `YingDistribution/Core/MonolithNavigation.swift:56-85` - 首页与其他页之间的切换方式，决定入口设计不要破坏全局体验

  **Acceptance Criteria**:
  - [ ] 五项功能均有清晰可发现入口
  - [ ] 首页层次清晰，无明显 UI 拥挤
  - [ ] 所有关联空状态都可正确呈现
  - [ ] 原有 dashboard 核心指标与分层模块仍可正常工作

  **QA Scenarios**:
  ```
  Scenario: 首页可发现全部新功能且层次稳定
    Tool: Runtime verification
    Preconditions: 所有模块已接入
    Steps:
      1. 启动 app 进入 dashboard
      2. 确认历史、preset、导出、对比、insight 均可被发现
      3. 检查滚动、布局、卡片高度与点击区域
    Expected Result: 首页可用、可读、无重叠错位
    Failure Indicators: 元素被遮挡、滚动异常、入口难以发现
    Evidence: .sisyphus/evidence/task-10-dashboard-integration.txt

  Scenario: 多种空状态正确退化
    Tool: Runtime verification
    Preconditions: 清空历史、preset，且当前无结果
    Steps:
      1. 打开 dashboard
      2. 分别触发历史、对比、导出、insight 区相关入口
      3. 观察空状态与禁用态反馈
    Expected Result: 全部走到清晰空状态，无崩溃
    Evidence: .sisyphus/evidence/task-10-empty-matrix.txt
  ```

  **Commit**: NO

- [x] 11. 持久化恢复、边界异常、证据采集收口

  **What to do**:
  - 对历史、preset、comparison、export、insight 进行跨模块恢复与异常收口
  - 验证应用重启后的 latest/history/preset 恢复、无数据保护、坏数据回退、命名冲突、导出失败提示
  - 补齐执行证据采集路径，确保 final verification 可基于证据复核

  **Must NOT do**:
  - 不在此阶段额外扩功能
  - 不新增新的业务页面或新概念

  **Recommended Agent Profile**:
  - **Category**: `deep`
    - Reason: 该任务是跨模块收口，重点在依赖关系、异常矩阵和回归验证
  - **Skills**: `[]`
  - **Skills Evaluated but Omitted**:
    - `review-work`: 最终总复核阶段才适用

  **Parallelization**:
  - **Can Run In Parallel**: NO
  - **Parallel Group**: Sequential end of Wave 3
  - **Blocks**: F1, F2, F3, F4
  - **Blocked By**: 1, 5, 6, 7, 8, 9, 10

  **References**:
  - `YingDistribution/Services/CarmineArchivist.swift:20-34` - 所有恢复路径最终都要回到 archivist 的读取能力
  - `YingDistribution/ViewModels/VermilionDashboardVM.swift:55-63` - 当前 restoreArchived 是重启恢复的已知入口
  - `YingDistribution/Services/IndigoExporter.swift:66-85` - 导出与分享的最终用户路径，需纳入失败回退验证
  - `.sisyphus/plans/app-store-hardening-plan.md` - 本计划内所有 QA 场景与证据命名要求

  **Acceptance Criteria**:
  - [ ] 应用重启后 latest/history/preset 恢复正常
  - [ ] 边界异常矩阵至少覆盖坏数据、无数据、命名冲突、选择不足、导出无结果
  - [ ] 所有任务证据文件已按命名规则输出

  **QA Scenarios**:
  ```
  Scenario: 重启后恢复矩阵验证
    Tool: Runtime verification
    Preconditions: 已存在 latest metrics、history、preset
    Steps:
      1. 完全关闭 app
      2. 重新启动并进入 dashboard/history/preset 页面
      3. 检查三类数据是否都能恢复
    Expected Result: 所有本地状态恢复成功
    Failure Indicators: 仅恢复 latest、history 丢失、preset 丢失、界面不同步
    Evidence: .sisyphus/evidence/task-11-recovery-matrix.txt

  Scenario: 边界异常总回归
    Tool: Runtime verification + Bash
    Preconditions: 能操作 UserDefaults / 导出入口 / 对比入口
    Steps:
      1. 测试空历史、空 preset、空 metrics、坏归档、对比仅选 1 条、导出无结果
      2. 记录每个异常场景反馈
      3. 汇总到统一证据文件
    Expected Result: 所有异常均被显式处理，无 crash
    Evidence: .sisyphus/evidence/task-11-edge-regression.txt
  ```

  **Commit**: NO

---

## Final Verification Wave

- [x] F1. **Plan Compliance Audit** — `oracle` ✅ APPROVE — Must Have 4/4, Must NOT Have 5/5, Tasks 11/11
- [x] F2. **Code Quality Review** — `unspecified-high` ✅ APPROVE — Build PASS, Files 5 clean/0 issues
- [x] F3. **Real Manual QA** — `unspecified-high` ✅ APPROVE — Scenarios 7/7 pass, Edge Cases 7 tested
  从干净状态执行所有 QA 场景，覆盖历史、preset、对比、导出、insight、空状态、恢复与异常场景，并把证据集中到 `.sisyphus/evidence/final-qa/`。
  Output: `Scenarios [N/N pass] | Edge Cases [N tested] | VERDICT`

- [x] F4. **Scope Fidelity Check** — `deep` ✅ APPROVE — 11/11 compliant, no out-of-scope additions
  用实际改动与计划逐条比对，确认没有额外扩展到云同步、自动化测试搭建、术语重写、大规模导航重构等范围外内容。
  Output: `Tasks [N/N compliant] | Unaccounted [CLEAN/N files] | VERDICT`

---

## Commit Strategy

- **Suggested grouping**:
  - `feat(storage): add local history preset and comparison archives`
  - `feat(dashboard): add insights and navigation entry points`
  - `feat(export): add pdf csv share flow`
  - `feat(compare): add experiment comparison screen`

---

## Success Criteria

### Verification Commands
```bash
xcodebuild -project YingDistribution.xcodeproj -scheme YingDistribution -destination 'platform=iOS Simulator,name=iPhone 15' build
```

### Final Checklist
- [ ] 五项功能全部存在并可达
- [ ] 所有新增数据均仅保存在本地
- [ ] 应用重启后 latest/history/preset 可恢复
- [ ] CSV / PDF 导出均成功
- [ ] 对比功能仅限双实验且可正确阻止非法选择
- [ ] insight 卡片与当前结果一致
- [ ] 所有 QA 证据文件齐全
