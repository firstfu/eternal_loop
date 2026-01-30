# 永恆之環 - Xcode 專案設置指南

本指南說明如何完成專案的最終設置。**大部分設置已自動完成**，你只需要完成以下步驟。

## 當前狀態

✅ **已完成：**
- Widget Extension (EternalLoopWidget) target 已創建
- App Clip (eternal_loop_Clip) target 已創建
- App Groups 已配置 (`group.com.eternal-loop`)
- 共享源代碼已添加到 App Clip target
- 所有檔案路徑已修復

## 前置需求

- Xcode 15.0 或更高版本
- Apple Developer 帳號
- iOS 17.0 或更高版本的裝置/模擬器

## 步驟 1: 開啟專案

```bash
cd /Users/firstfu/Desktop/eternal_loop
open eternal_loop.xcodeproj
```

## 步驟 2: 在 Apple Developer Portal 配置

### 2.1 配置 App Groups

1. 登入 [Apple Developer Portal](https://developer.apple.com)
2. 前往 **Certificates, Identifiers & Profiles**
3. 選擇 **Identifiers → App Groups**
4. 點擊 **+** 創建新的 App Group
5. 輸入: `group.com.eternal-loop`
6. 點擊 **Continue** 然後 **Register**

### 2.2 配置 App IDs

確保以下 App IDs 已創建並啟用所需 capabilities:

| App ID | Capabilities |
|--------|-------------|
| `com.firstfu.com.eternal-loop` | App Groups, Push Notifications, Associated Domains |
| `com.firstfu.com.eternal-loop.Widget` | App Groups |
| `com.firstfu.com.eternal-loop.Clip` | App Groups, Associated Domains |

### 2.3 更新 Provisioning Profiles

為每個 App ID 創建或更新 Provisioning Profile，確保包含上述 capabilities。

## 步驟 3: 在 Xcode 中驗證設置

### 3.1 選擇開發團隊

1. 開啟專案
2. 對於每個 target (eternal_loop, EternalLoopWidget, eternal_loop_Clip):
   - 選擇 target
   - 前往 **Signing & Capabilities**
   - 選擇你的 **Team**
   - 確保 **Automatically manage signing** 已勾選

### 3.2 驗證 App Groups

確認所有三個 targets 的 App Groups 配置相同:
- `group.com.eternal-loop`

## 步驟 4: 添加 AppIcon

為主應用和 App Clip 添加應用圖標:

1. 準備 1024x1024 的 PNG 圖標
2. 將圖標添加到:
   - `eternal_loop/Assets.xcassets/AppIcon.appiconset/`
   - `eternal_loop_Clip/Assets.xcassets/AppIcon.appiconset/`

## 步驟 5: 驗證建置

### 5.1 建置所有 targets

```bash
xcodebuild build -scheme eternal_loop -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

預期結果: `** BUILD SUCCEEDED **`

### 5.2 運行測試

```bash
xcodebuild test -scheme eternal_loop \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

## 步驟 6: 配置 Universal Links (可選)

如果要使用 App Clip 的 Universal Links 功能:

### 6.1 設置 Apple App Site Association

在你的伺服器上創建 `.well-known/apple-app-site-association` 文件:

```json
{
  "appclips": {
    "apps": ["TEAM_ID.com.firstfu.com.eternal-loop.Clip"]
  },
  "applinks": {
    "apps": [],
    "details": [{
      "appID": "TEAM_ID.com.firstfu.com.eternal-loop",
      "paths": ["*"]
    }]
  }
}
```

將 `TEAM_ID` 替換為你的 Apple Developer Team ID。

### 6.2 更新 Associated Domains

目前配置的 domains:
- 主應用: `appclips:eternal-loop.com`
- App Clip: `appclips:eternalloop.app`

根據你的實際域名修改這些設置。

## 故障排除

### 「Provisioning Profile doesn't include capability」

1. 在 Developer Portal 中更新 App ID 的 capabilities
2. 刪除舊的 Provisioning Profile
3. 在 Xcode 中取消勾選再重新勾選 "Automatically manage signing"

### Widget 不顯示在主畫面

1. 確認主應用至少運行過一次
2. 長按主畫面 → 點擊 **+** → 搜尋「永恆之環」
3. 確認 Widget Extension 已正確簽名

### App Clip 無法啟動

1. 使用 **Developer Settings** 中的 **Local Experiences** 測試
2. 確認 Associated Domains 正確配置
3. 檢查 App Clip 的 entitlements 文件

### 建置錯誤「file not found」

專案已包含修復腳本，如遇到問題可運行:

```bash
ruby Scripts/fix_file_paths_correct.rb
```

## 專案結構

```
eternal_loop/
├── eternal_loop/           # 主應用源代碼
│   ├── Core/               # 核心功能
│   │   ├── Models/         # 資料模型
│   │   ├── Connectivity/   # 連線管理
│   │   ├── Haptics/        # 觸覺反饋
│   │   ├── AR/             # AR 功能
│   │   └── DesignSystem/   # UI 設計系統
│   └── Features/           # 功能模組
├── EternalLoopWidget/      # Widget Extension
├── eternal_loop_Clip/      # App Clip
├── Scripts/                # 建置腳本
└── docs/                   # 文檔
```

## 完成

完成上述步驟後，你應該能夠:
- ✅ 建置並運行主應用
- ✅ 在主畫面添加 Widget
- ✅ 通過 QR Code 或連結啟動 App Clip
- ✅ 使用 App Groups 在應用間共享資料

如有問題，請參考 Apple 官方文檔:
- [App Clips](https://developer.apple.com/documentation/app_clips)
- [WidgetKit](https://developer.apple.com/documentation/widgetkit)
- [Nearby Interaction](https://developer.apple.com/documentation/nearbyinteraction)
