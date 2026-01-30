# Widget Extension 設置指南

本文檔說明如何在 Xcode 中設置 Widget Extension。

## 步驟 1: 創建 Widget Extension Target

1. 在 Xcode 中打開專案
2. 選擇 **File → New → Target...**
3. 搜尋 **Widget Extension**
4. 點擊 **Next**
5. 填寫以下資訊:
   - **Product Name**: `EternalLoopWidget`
   - **Team**: 選擇你的開發團隊
   - **Include Configuration App Intent**: 取消勾選
6. 點擊 **Finish**
7. 如果詢問是否 Activate scheme，選擇 **Activate**

## 步驟 2: 設置 App Groups

Widget 需要與主 App 共享數據，需要設置 App Groups。

### 主 App 設置:
1. 選擇主 App target
2. 選擇 **Signing & Capabilities** 標籤
3. 點擊 **+ Capability**
4. 添加 **App Groups**
5. 點擊 **+** 添加新的 group
6. 輸入: `group.com.eternal-loop`

### Widget Extension 設置:
1. 選擇 Widget Extension target
2. 選擇 **Signing & Capabilities** 標籤
3. 點擊 **+ Capability**
4. 添加 **App Groups**
5. 選擇同一個 group: `group.com.eternal-loop`

## 步驟 3: 複製 Widget 代碼

1. 刪除自動生成的 Widget 代碼文件
2. 將 `EternalLoopWidget.swift` 複製到 Widget Extension 目錄
3. 確保文件在正確的 target 中（只在 Widget Extension target）

## 步驟 4: 更新主 App 以保存數據

在主 App 中添加以下代碼來保存數據供 Widget 讀取：

```swift
import WidgetKit

// 當儀式完成時調用
func saveWidgetData(partnerName: String, ceremonyDate: Date) {
    let userDefaults = UserDefaults(suiteName: "group.com.eternal-loop")
    userDefaults?.set(partnerName, forKey: "partnerName")
    userDefaults?.set(ceremonyDate, forKey: "ceremonyDate")

    // 通知 Widget 更新
    WidgetCenter.shared.reloadAllTimelines()
}
```

## 步驟 5: 更新 Info.plist

確保 Widget Extension 的 Info.plist 包含正確的配置。

## 步驟 6: 測試

1. 選擇 Widget Extension scheme
2. 運行到模擬器或真機
3. 長按主畫面添加 Widget
4. 搜尋 "永恆之環"
5. 選擇小型或中型 Widget

## 故障排除

### Widget 不顯示數據
- 確認 App Groups 配置正確
- 確認主 App 有調用 `saveWidgetData`
- 確認 UserDefaults suite name 一致

### Widget 無法添加
- 確認 Widget Extension 已正確簽名
- 確認 Provisioning Profile 包含 App Groups capability

## 注意事項

- Widget 更新頻率由系統控制
- 用戶可以手動更新 Widget（長按 → 編輯 Widget）
- 建議在儀式完成後立即調用 `WidgetCenter.shared.reloadAllTimelines()`
