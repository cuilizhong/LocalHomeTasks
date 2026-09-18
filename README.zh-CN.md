# LocalHomeTasks

语言：[English](README.md) | 中文

LocalHomeTasks 是一个本地优先的 iOS 应用，用于跟踪周期性家庭维护任务、即将到期的事项、逾期任务以及可选的本地提醒。

应用使用 Swift 和 SwiftUI 构建，采用简洁的扁平化视觉风格、本地 JSON 持久化和 iOS 本地通知。它适合管理常见的家庭维护工作，例如更换 HVAC 滤芯、检查烟雾报警器、清理烘干机通风口、维护家电等。

## 功能

- Dashboard 显示逾期、即将到期和总任务数量
- 按下次到期日期排序的 upcoming task 预览
- 完整任务列表，支持新增、编辑、删除和完成
- 任务详情页展示到期日期、重复周期、提醒、备注和完成状态
- 支持 monthly 和 yearly 两种重复周期
- 完成任务后自动推进下一次到期日期
- 对月末日期和闰年年度周期有一致处理
- 使用 iOS 本地通知安排提醒
- 简单的提醒设置
- 本地存储，关闭应用后任务仍然保留
- Debug 环境自动生成示例数据，方便预览和测试
- 扁平化 App 图标和一致的启动展示页

## App 流程

应用包含三个主要 Tab：

### Dashboard

Dashboard 用于快速查看家庭维护状态：

- 逾期数量
- 即将到期数量
- 总任务数量
- 最近即将到期的任务

### Tasks

任务列表是主要管理页面：

- 查看所有任务，并按下一次到期日期排序
- 打开任务详情
- 标记任务完成
- 删除任务
- 新增周期性任务

### Settings

设置页专注于提醒行为：

- 全局启用或关闭提醒
- 设置默认提醒提前天数
- 调整 Dashboard 使用的 due-soon 时间窗口

## 设计

LocalHomeTasks 使用适合工具类 App 的扁平、实用视觉风格。

设计规则：

- 不使用渐变
- 不使用阴影
- 不使用玻璃效果
- 不使用装饰性背景图形
- 使用系统字体
- 使用 SF Symbols 表示操作和状态
- 使用细边框表达层级，不使用 elevation
- 使用绿色作为家庭维护和完成状态的主色

主题色：

- 主绿色：`#1A7352`
- 背景：暖白色
- Surface：白色
- Overdue：红色
- Due soon：琥珀色
- Upcoming：绿色

## 架构

应用采用轻量 SwiftUI 架构，将 UI、状态、持久化和服务逻辑分离。

```text
LocalHomeTasks/
  Components/
    EmptyStateView.swift
    MetricBlockView.swift
    StatusBadge.swift
    TaskRowView.swift

  Models/
    MaintenanceTask.swift
    RecurrenceRule.swift
    ReminderSettings.swift
    SampleTasks.swift
    TaskStatus.swift

  Persistence/
    JSONTaskPersistence.swift
    SettingsPersistence.swift
    TaskPersistence.swift

  Services/
    DateProvider.swift
    NotificationScheduler.swift
    RecurrenceCalculator.swift
    TaskStatusResolver.swift

  Stores/
    TaskStore.swift

  Theme/
    AppColor.swift
    AppSpacing.swift

  Views/
    DashboardView.swift
    SettingsView.swift
    SplashView.swift
    TaskDetailView.swift
    TaskFormView.swift
    TaskListView.swift

  ContentView.swift
  LocalHomeTasksApp.swift
```

### 主要分层

| 层级 | 职责 |
| --- | --- |
| Views | SwiftUI 页面和用户交互 |
| Components | 可复用 UI 组件 |
| Store | 任务状态、数据变更、Dashboard 统计和服务协调 |
| Persistence | 本地 JSON 任务存储和 UserDefaults 设置 |
| Services | 日期周期计算、状态判断、通知调度、日期提供 |
| Models | 可编码的任务和设置数据 |

## 重复周期逻辑

重复日期逻辑集中在 `RecurrenceCalculator` 中。

Monthly 任务：

- 按日历月份推进一个月
- 保持实用的月末行为
- 示例：January 31 -> February 28 或 February 29
- 示例：March 31 -> April 30

Yearly 任务：

- 按日历年份推进一年
- 一致处理闰日计划
- 示例：February 29, 2024 -> February 28, 2025

逾期任务完成：

- 完成逾期任务时，会从当前 due date 开始持续推进，直到新的 due date 位于未来
- 这样可以避免任务完成后仍然立即显示为逾期

示例：

```text
Monthly task due May 1
Completed September 18
Next due date becomes October 1
```

## 本地通知

应用使用 `UserNotifications` 实现提醒。

提醒行为：

- 启用提醒时请求通知权限
- 每个任务安排一个 pending notification
- 编辑任务会重新安排提醒
- 完成任务会推进 due date 并重新安排提醒
- 删除任务会取消提醒
- 已经过期的提醒日期会跳过

## 本地存储

任务以 JSON 文件形式存储在应用 Documents 目录中。

设置使用 `UserDefaults` 存储。

应用不使用：

- 账号
- 云同步
- 共享家庭
- 远程 API
- 内购

## Debug 示例数据

Debug 构建会在本地存储为空时自动创建示例任务。

示例数据包括：

- 逾期 monthly 任务
- 即将到期 monthly 任务
- upcoming monthly 任务
- upcoming yearly 任务
- 逾期 yearly 任务

这样启动应用后可以立即查看 Dashboard 和任务状态 UI。

开发过程中如需重置示例数据，可以从模拟器或真机删除应用后重新运行。

## 环境要求

- Xcode 15 或更新版本
- iOS 17 或更新版本
- SwiftUI

## 运行应用

1. 使用 Xcode 打开 `LocalHomeTasks.xcodeproj`。
2. 选择 `LocalHomeTasks` scheme。
3. 选择 iPhone 模拟器或连接的 iPhone。
4. 使用 `Cmd + R` 构建并运行。
5. 如果需要测试提醒，请允许通知权限。

## 项目备注

- UI 使用 SwiftUI 的 Observation 系统，通过 `@Observable` 管理状态。
- `TaskStore` 使用 `@MainActor`，因为它会更新 UI 观察的状态。
- 日期相关逻辑被独立出来，便于测试。
- 通知服务不持有任务数据，只负责安排和取消提醒。
- App 图标使用 `AppIcon.appiconset` 中的 PNG 资源，因为 iOS App 图标不支持 SVG 引用。

## 验证重点

最重要的验证点是重复日期行为：

- Monthly 周期
- 月末日期
- Yearly 周期
- 闰日年度周期
- 完成逾期任务
- 逾期、即将到期和 upcoming 状态判断

这些规则都在 UI 外部实现，后续可以用聚焦的单元测试覆盖。

