# AI Planner - Project Resume / 项目简历

---

## English Version

### AI Planner — Intelligent Task Management iOS App

**Tech Stack:** Swift · SwiftUI · Combine · AWS Amplify (Cognito) · Moonshot LLM API · UserNotifications

**GitHub:** [github.com/JudyZhu45/AI_planner]

#### Overview

Independently designed and developed a full-stack iOS task management application that integrates a large language model (LLM) to enable natural language schedule planning, task CRUD operations, and multi-day planning through conversational AI — all within a polished, production-grade SwiftUI interface.

#### Technical Highlights

- **LLM-Powered Agent with Structured Output Parsing**
  Engineered a conversational AI agent that interprets natural language and emits structured `[ACTION]` JSON directives embedded in streaming responses. Built a custom regex-based parser that extracts action blocks in real-time from Server-Sent Events (SSE) streams, executes CRUD operations against the local data layer, and strips raw JSON from the user-facing UI — achieving a seamless "chat-to-action" UX.

- **Two-Phase Confirmation Workflow**
  Designed a proposal-then-confirm interaction pattern: the AI first presents a plan in natural language, then only executes task mutations upon explicit user confirmation. Implemented keyword-based proposal detection and a one-tap confirm UI, balancing automation convenience with user control.

- **Real-Time Streaming Chat with Undo Support**
  Built a streaming chat interface using `URLSession.bytes(for:)` and `AsyncThrowingStream`, delivering token-by-token rendering with live `[ACTION]` block filtering (including incomplete blocks during mid-stream). Each AI-executed action is tracked with full undo metadata (previous task state snapshots), enabling one-tap reversal of creates, updates, deletes, and completions.

- **MVVM Architecture with Reactive State Management**
  Structured the app around a strict MVVM pattern with `@StateObject`, `@ObservedObject`, `@Published`, and `@Observable` (Swift 5.9 macro). Isolated all AI orchestration into a dedicated service layer (`ChatService` → `KimiAPIService`), cleanly separating network I/O, action parsing, and UI state.

- **Dynamic Context Injection for LLM Accuracy**
  The system prompt is rebuilt on every API call with the user's current task list (UUIDs, dates, times, priorities), segmented into overdue / this-week / future buckets. This gives the LLM accurate scheduling context to avoid time conflicts and reference existing tasks by ID — a technique that significantly improves action reliability over static prompts.

- **AWS Cognito Authentication**
  Implemented a complete authentication flow — sign-up, email verification (6-digit code), sign-in, password reset — using AWS Amplify Auth with Cognito. Managed auth state globally with `@Observable` and routed between auth and main views based on session status.

- **Custom Design System & Component Library**
  Built a comprehensive `AppTheme` design system: 12 typography levels, 6 event-type color palettes (with light/dark variants), 5 shadow levels, and a consistent spacing/radius scale. Extracted 13+ reusable components (MessageBubble, ScheduleCard, TypingIndicator, etc.) with configurable callbacks.

- **Gesture-Driven UI**
  Implemented a draggable floating action button with `DragGesture`, snap-to-edge physics via spring animation, and vertical clamping. Added swipe-to-delete (leading edge) and swipe-to-complete (trailing edge) on task cards.

- **Smart Local Notifications**
  Scheduled context-aware reminders: 15 minutes before timed events, 8:00 AM on due date for untimed todos. Handles automatic cancellation on task completion and skips past dates.

- **Conversation Memory Management**
  Implemented sliding-window context trimming (last 20 messages to API, last 50 persisted locally) to control token costs while maintaining conversation coherence.

---

## 中文版本

### AI Planner — 智能任务管理 iOS 应用

**技术栈：** Swift · SwiftUI · Combine · AWS Amplify (Cognito) · Moonshot LLM API · UserNotifications

**GitHub:** [github.com/JudyZhu45/AI_planner]

#### 概述

独立设计并开发了一款全栈 iOS 任务管理应用，集成大语言模型（LLM），支持通过自然语言对话实现日程规划、任务增删改查、多日计划生成，同时具备生产级别的 SwiftUI 界面和完整的用户体验。

#### 技术亮点

- **基于 LLM 的智能 Agent 与结构化输出解析**
  设计并实现了一个对话式 AI Agent，能够理解自然语言并在流式响应中嵌入结构化 `[ACTION]` JSON 指令。自研基于正则表达式的实时解析器，从 SSE（Server-Sent Events）流中逐步提取 ACTION 块，执行本地数据层的 CRUD 操作，并从用户界面中过滤原始 JSON——实现了无缝的"对话即操作"交互体验。

- **两步确认工作流**
  设计了"先提案后确认"的交互模式：AI 首先用自然语言展示规划方案，仅在用户明确确认后才执行任务变更。实现了基于关键词的提案检测和一键确认 UI，在自动化便利性与用户控制权之间取得平衡。

- **实时流式聊天与撤销支持**
  使用 `URLSession.bytes(for:)` 和 `AsyncThrowingStream` 构建流式聊天界面，实现逐 token 渲染，并在流式传输过程中实时过滤 `[ACTION]` 块（包括不完整的中间状态块）。每个 AI 执行的操作都附带完整的撤销元数据（任务状态快照），支持一键撤销创建、更新、删除和完成操作。

- **MVVM 架构与响应式状态管理**
  采用严格的 MVVM 架构，综合使用 `@StateObject`、`@ObservedObject`、`@Published` 和 Swift 5.9 的 `@Observable` 宏。将 AI 编排逻辑隔离到独立服务层（`ChatService` → `KimiAPIService`），实现网络 I/O、动作解析和 UI 状态的清晰分离。

- **动态上下文注入提升 LLM 准确性**
  每次 API 调用前动态重建系统提示，注入用户当前任务列表（UUID、日期、时间、优先级），按"逾期/本周/未来"分段组织。使 LLM 能精确感知日程上下文、避免时间冲突、通过 ID 引用已有任务——相比静态提示，显著提升了操作可靠性。

- **AWS Cognito 用户认证**
  基于 AWS Amplify Auth + Cognito 实现完整认证流程：注册、邮箱验证（6位验证码）、登录、密码重置。使用 `@Observable` 全局管理认证状态，根据会话状态路由认证页面与主界面。

- **自研设计系统与组件库**
  构建了完整的 `AppTheme` 设计系统：12 级字体排版、6 种事件类型配色方案（含亮/暗变体）、5 级阴影系统、统一的间距与圆角规范。提取了 13+ 可复用组件（MessageBubble、ScheduleCard、TypingIndicator 等），支持回调配置。

- **手势驱动的交互设计**
  实现可拖拽的浮动操作按钮（FAB），使用 `DragGesture` + 弹簧动画实现边缘吸附和垂直范围约束。任务卡片支持左滑删除、右滑完成的手势操作。

- **智能本地通知**
  实现上下文感知的提醒调度：有时间的事件提前 15 分钟提醒，无时间的待办在截止日早上 8:00 提醒。支持任务完成后自动取消通知，自动跳过过期日期。

- **对话记忆管理**
  实现滑动窗口式上下文裁剪（API 请求保留最近 20 条消息，本地持久化最近 50 条），在控制 token 成本的同时保持对话连贯性。
