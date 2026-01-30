# 永恆之環 - Xcode 專案設置指南

本指南說明如何在 Xcode 中完成 App Clip 和 Widget Extension 的設置。

## 前置需求

- Xcode 15.0 或更高版本
- Apple Developer 帳號
- iOS 17.0 或更高版本的裝置/模擬器

## 步驟 1: 開啟專案

```bash
cd /Users/firstfu/Desktop/eternal_loop
open eternal_loop.xcodeproj
```

## 步驟 2: 設置 App Groups

### 2.1 主應用 (eternal_loop)

1. 在專案導覽器中選擇 **eternal_loop** 專案
2. 選擇 **eternal_loop** target
3. 點擊 **Signing & Capabilities** 標籤
4. 點擊 **+ Capability** 按鈕
5. 搜尋並添加 **App Groups**
6. 點擊 **+** 添加新的 group
7. 輸入: `group.com.eternal-loop`

### 2.2 App Clip (eternal_loop_Clip)

重複上述步驟，為 App Clip target 添加相同的 App Group。

## 步驟 3: 設置 Widget Extension

### 3.1 創建 Widget Extension Target

1. 選擇 **File → New → Target...**
2. 搜尋並選擇 **Widget Extension**
3. 點擊 **Next**
4. 填寫資訊:
   - **Product Name**: `EternalLoopWidget`
   - **Team**: 選擇你的開發團隊
   - **Include Configuration App Intent**: ❌ 取消勾選
   - **Include Live Activity**: ❌ 取消勾選
5. 點擊 **Finish**
6. 當詢問是否 Activate scheme 時，選擇 **Activate**

### 3.2 替換 Widget 代碼

1. 刪除自動生成的 Widget 文件
2. 將 `eternal_loop/Widget/EternalLoopWidget.swift` 拖拽到 Widget Extension group 中
3. 確保文件 target 設置為 **EternalLoopWidget**

### 3.3 添加 App Groups 到 Widget

1. 選擇 **EternalLoopWidget** target
2. 點擊 **Signing & Capabilities**
3. 添加 **App Groups** capability
4. 選擇同一個 group: `group.com.eternal-loop`

### 3.4 設置 Widget Info.plist

確保 Widget 的 Info.plist 包含以下內容:

```xml
<key>NSExtension</key>
<dict>
    <key>NSExtensionPointIdentifier</key>
    <string>com.apple.widgetkit-extension</string>
</dict>
```

## 步驟 4: 設置 App Clip

### 4.1 創建 App Clip Target

1. 選擇 **File → New → Target...**
2. 搜尋並選擇 **App Clip**
3. 點擊 **Next**
4. 填寫資訊:
   - **Product Name**: `eternal_loop_Clip`
   - **Team**: 選擇你的開發團隊
5. 點擊 **Finish**

### 4.2 替換 App Clip 代碼

1. 刪除自動生成的 App Clip 文件
2. 將 `eternal_loop_Clip/` 目錄中的文件拖拽到新創建的 App Clip group 中
3. 確保所有文件的 target 設置為 **eternal_loop_Clip**

### 4.3 添加 App Groups 到 App Clip

1. 選擇 **eternal_loop_Clip** target
2. 添加 **App Groups** capability
3. 選擇: `group.com.eternal-loop`

### 4.4 添加 Associated Domains

1. 在 **eternal_loop_Clip** target 的 **Signing & Capabilities** 中
2. 添加 **Associated Domains** capability
3. 點擊 **+** 添加 domain
4. 輸入: `appclips:eternal-loop.com`

### 4.5 配置主應用嵌入 App Clip

1. 選擇 **eternal_loop** 主 target
2. 點擊 **General** 標籤
3. 滾動到 **Frameworks, Libraries, and Embedded Content**
4. 點擊 **+** 按鈕
5. 選擇 **eternal_loop_Clip.app**
6. 設置 Embed 為 **Embed & Sign**

## 步驟 5: 配置 Nearby Interaction

1. 選擇 **eternal_loop** target
2. 確保 entitlements 文件包含:
   ```xml
   <key>com.apple.developer.nearby-interaction</key>
   <true/>
   ```

3. 確保 Info.plist 包含使用說明:
   ```xml
   <key>NSNearbyInteractionUsageDescription</key>
   <string>用於測量兩台裝置之間的距離，實現求婚儀式的互動體驗</string>
   ```

## 步驟 6: 驗證設置

### 6.1 建置主應用

```bash
xcodebuild build -scheme eternal_loop -configuration Debug -destination 'generic/platform=iOS'
```

### 6.2 建置 Widget

```bash
xcodebuild build -scheme EternalLoopWidget -configuration Debug -destination 'generic/platform=iOS'
```

### 6.3 建置 App Clip

```bash
xcodebuild build -scheme eternal_loop_Clip -configuration Debug -destination 'generic/platform=iOS'
```

## 步驟 7: 運行測試

```bash
xcodebuild test -scheme eternal_loop -destination 'platform=iOS Simulator,name=iPhone 17'
```

## 故障排除

### Bundle Identifier 衝突

確保每個 target 使用唯一的 Bundle Identifier:
- 主應用: `com.firstfu.com.eternal-loop`
- App Clip: `com.firstfu.com.eternal-loop.Clip`
- Widget: `com.firstfu.com.eternal-loop.Widget`

### App Groups 不生效

1. 確認所有 targets 都使用相同的 App Group ID
2. 確認 Provisioning Profile 包含 App Groups capability
3. 在 Apple Developer Portal 中創建 App Group

### Widget 不顯示

1. 確認 Widget Extension 已正確簽名
2. 在模擬器中長按主畫面，搜尋 "永恆之環"
3. 確認主應用至少運行過一次

### App Clip 無法啟動

1. 確認 Associated Domains 配置正確
2. 確認主應用已嵌入 App Clip
3. 使用 App Clip Diagnostics 進行測試

## 完成

完成上述步驟後，你應該能夠:
- ✅ 建置並運行主應用
- ✅ 在主畫面添加 Widget
- ✅ 通過 QR Code 或連結啟動 App Clip
- ✅ 使用 UWB 進行距離偵測

如有問題，請參考 Apple 官方文檔:
- [App Clips](https://developer.apple.com/documentation/app_clips)
- [WidgetKit](https://developer.apple.com/documentation/widgetkit)
- [Nearby Interaction](https://developer.apple.com/documentation/nearbyinteraction)
