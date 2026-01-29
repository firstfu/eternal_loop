# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

eternal_loop 是一個 iOS 應用程式，使用 SwiftUI 和 SwiftData 框架建構。目前是基礎模板狀態，包含簡單的 Item 資料模型與 CRUD 操作。

- **平台**: iOS (iPhone/iPad)
- **最低版本**: iOS 26.2
- **語言**: Swift 5.0
- **框架**: SwiftUI, SwiftData

## Build and Test Commands

```bash
# 在 Xcode 中開啟專案
open eternal_loop.xcodeproj

# 建置專案
xcodebuild build -scheme eternal_loop -configuration Debug

# 執行所有測試
xcodebuild test -scheme eternal_loop

# 僅執行單元測試
xcodebuild test -scheme eternal_loop -only-testing:eternal_loopTests

# 僅執行 UI 測試
xcodebuild test -scheme eternal_loop -only-testing:eternal_loopUITests

# 建置 Release 版本
xcodebuild build -scheme eternal_loop -configuration Release
```

## Architecture

專案採用 SwiftUI + SwiftData 的標準架構：

```
eternal_loopApp (應用程式進入點)
    ├── ModelContainer 初始化 (SwiftData 資料容器)
    └── ContentView (根視圖)
            ├── @Environment(\.modelContext) 資料操作
            ├── @Query 資料查詢
            └── NavigationSplitView UI 結構
```

### 關鍵檔案

- `eternal_loopApp.swift` - 應用程式進入點，設定 SwiftData ModelContainer
- `ContentView.swift` - 主要 UI 視圖，包含列表顯示與 CRUD 操作
- `Item.swift` - SwiftData 資料模型 (@Model)

### 資料流

1. `eternal_loopApp` 建立 `ModelContainer` 並透過 `.modelContainer()` 修飾器注入環境
2. `ContentView` 使用 `@Environment(\.modelContext)` 取得資料操作上下文
3. `@Query` 屬性包裝器自動查詢並監聽 Item 資料變更

## Configured Capabilities

- 推送通知 (development environment)
- CloudKit (已啟用但未設定容器)
- 背景模式: remote-notification
