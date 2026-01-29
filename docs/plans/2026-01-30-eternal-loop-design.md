# 永恆之環 (Eternal Loop) - 設計文件

> 數位求婚 App 完整設計規格
> 版本：1.0
> 日期：2026-01-30

---

## 1. 產品概述

**永恆之環 (Eternal Loop)** 是一款 iOS 數位求婚 App，透過兩台 iPhone 的 UWB 近距離感應與 AR 技術，將求婚儀式數位化。

### 核心流程

1. Host（求婚者）設定戒指款式、暱稱、告白宣言
2. Guest（被求婚者）掃描 QR Code 啟動 App Clip
3. 兩機靠近，心跳震動同步加速
4. Host 滑動傳送戒指，戒指「飛入」Guest 螢幕
5. Guest 手伸入鏡頭，ARKit 自動追蹤並戴上戒指
6. 系統生成精美數位證書

### 技術架構

| 模組 | 技術 |
|------|------|
| UI 框架 | SwiftUI |
| 資料持久化 | SwiftData |
| 設備通訊 | Multipeer Connectivity |
| 距離測量 | Nearby Interaction (UWB) |
| 3D 渲染 | RealityKit |
| 手部追蹤 | ARKit Vision |
| 觸覺回饋 | Core Haptics |

**最低需求：** iOS 17+、iPhone 11+ (U1/U2 晶片)

---

## 2. App 結構與模組劃分

```
eternal_loop/
├── App/
│   ├── eternal_loopApp.swift      # 主 App 進入點
│   └── AppClipApp.swift           # App Clip 進入點
│
├── Features/
│   ├── Setup/                     # Host 設定流程
│   │   ├── SetupView.swift
│   │   ├── RingSelectionView.swift
│   │   └── MessageInputView.swift
│   │
│   ├── Pairing/                   # QR Code 配對
│   │   ├── QRGeneratorView.swift
│   │   └── QRScannerView.swift
│   │
│   ├── Ceremony/                  # 核心求婚儀式
│   │   ├── HostCeremonyView.swift
│   │   ├── GuestCeremonyView.swift
│   │   └── RingTransferAnimation.swift
│   │
│   ├── AR/                        # AR 戴戒指體驗
│   │   ├── ARRingView.swift
│   │   └── HandTrackingManager.swift
│   │
│   └── Certificate/               # 證書生成
│       ├── CertificateView.swift
│       └── CertificateGenerator.swift
│
├── Core/
│   ├── Connectivity/              # 設備連線
│   │   ├── MultipeerManager.swift
│   │   └── NearbyInteractionManager.swift
│   │
│   ├── Haptics/                   # 觸覺回饋
│   │   └── HeartbeatHaptics.swift
│   │
│   └── Models/                    # 資料模型
│       ├── ProposalSession.swift
│       └── Ring.swift
│
└── Resources/
    ├── RingModels/                # 3D 戒指模型 (.usdz)
    └── ParticleEffects/           # 粒子特效
```

### 共用模組（主 App 與 App Clip）

App Clip 需包含完整儀式體驗，因此以下模組**共用**：
- `Ceremony/`、`AR/`、`Certificate/`
- `Core/` 全部
- `Resources/` 全部

僅主 App 獨有：`Setup/`（App Clip 的 Guest 不需設定）

---

## 3. 資料模型與狀態管理

### 核心資料模型

```swift
// 求婚 Session（SwiftData 持久化）
@Model
class ProposalSession {
    var id: UUID
    var hostNickname: String
    var guestNickname: String
    var message: String              // 告白宣言
    var selectedRing: RingType
    var createdAt: Date
    var completedAt: Date?
    var certificateImageData: Data?  // 生成的證書圖片
}

// 戒指類型（輕量列舉）
enum RingType: String, Codable, CaseIterable {
    case classicSolitaire    // 經典單鑽
    case haloLuxury          // 奢華光環
    case minimalistBand      // 簡約素圈

    var modelFileName: String { /* 對應 .usdz 檔名 */ }
    var displayName: String { /* 顯示名稱 */ }
}

// 跨設備傳輸的訊息（Codable）
struct CeremonyMessage: Codable {
    enum MessageType: String, Codable {
        case sessionInfo       // Host → Guest：暱稱、戒指、宣言
        case distanceUpdate    // 雙向：UWB 距離同步
        case readyToSend       // Host → Guest：準備傳送
        case ringSent          // Host → Guest：戒指已發送
        case ringReceived      // Guest → Host：戒指已收到
        case ceremonyComplete  // 雙向：儀式完成
    }
    var type: MessageType
    var payload: Data?
}
```

### 狀態管理

```swift
@Observable
class CeremonyState {
    var phase: CeremonyPhase = .searching
    var distance: Float = .infinity      // UWB 測得距離（公尺）
    var isConnected: Bool = false
    var partnerNickname: String = ""
    var ring: RingType = .classicSolitaire
    var message: String = ""
}

enum CeremonyPhase {
    case searching      // 尋找對方中
    case approaching    // 靠近中（心跳同步）
    case readyToSend    // 準備傳送（< 5cm）
    case sending        // 傳送動畫中
    case arExperience   // AR 戴戒指
    case complete       // 儀式完成
}
```

---

## 4. 設備連線與 UWB 測距

### Multipeer Connectivity

```swift
class MultipeerManager: NSObject, ObservableObject {
    private let serviceType = "eternal-loop"  // Bonjour 服務名稱
    private var session: MCSession?
    private var advertiser: MCNearbyServiceAdvertiser?  // Guest 廣播
    private var browser: MCNearbyServiceBrowser?        // Host 搜尋
}
```

**配對流程：**
1. Guest 掃描 QR Code → App Clip 啟動 → 開始 Advertise
2. Host 點擊「開始配對」→ 開始 Browse
3. 發現對方 → 自動建立 MCSession
4. 交換 `NIDiscoveryToken` → 啟動 Nearby Interaction

### Nearby Interaction（UWB 測距）

```swift
class NearbyInteractionManager: NSObject, ObservableObject {
    private var niSession: NISession?
    @Published var distance: Float = .infinity  // 公尺
}
```

**距離 → 心跳對應表：**

| 距離 | 心跳間隔 | 視覺效果 |
|------|----------|----------|
| > 2m | 無 | 「尋找中...」文字 |
| 1-2m | 2.0 秒 | 柔和脈動光暈 |
| 0.2-1m | 1.0 秒 | 螢幕邊緣粉色發光 |
| 0.05-0.2m | 0.5 秒 | 「準備傳送」+ 強烈發光 |
| < 0.05m | 連續 | 自動觸發傳送（或等待滑動） |

**備案機制：** Host 長按螢幕右下角愛心圖示 3 秒，強制進入「準備傳送」狀態。

---

## 5. AR 戴戒指體驗

### ARKit 手部追蹤

```swift
class HandTrackingManager: ObservableObject {
    private var arSession: ARSession?
    private var handPoseRequest: VNDetectHumanHandPoseRequest?

    @Published var ringFingerPosition: CGPoint?  // 無名指位置
    @Published var isHandDetected: Bool = false
}
```

### RealityKit 戒指渲染

```swift
struct ARRingView: UIViewRepresentable {
    let ringType: RingType
    @Binding var ringFingerPosition: CGPoint?
    @Binding var shouldAttachRing: Bool
}
```

### 戒指套上流程

1. **戒指飛入**（1.5 秒）
   - 戒指從螢幕頂部飛入，帶有旋轉與光暈
   - 停在螢幕中央，提示「請將手伸入鏡頭」

2. **等待手部**
   - 偵測到手 → 戒指緩緩移向無名指
   - 未偵測到 → 持續顯示引導動畫

3. **戴上戒指**（2 秒）
   - 戒指滑入手指 + 縮放調整
   - 觸發金色光粒 + 愛心粒子特效
   - Core Haptics 強烈碰撞回饋

4. **完成**
   - 粒子漸淡，戒指停留在手指上
   - 顯示「截圖」與「生成證書」按鈕

---

## 6. 觸覺回饋與證書生成

### Core Haptics 心跳同步

```swift
class HeartbeatHaptics {
    private var engine: CHHapticEngine?
    private var heartbeatPlayer: CHHapticPatternPlayer?

    // 心跳模式：兩下連續敲擊（模擬真實心跳 lub-dub）
    func createHeartbeatPattern(intensity: Float) -> CHHapticPattern

    // 根據距離調整心跳頻率
    func updateHeartbeat(forDistance distance: Float)
}
```

### 證書生成

```swift
class CertificateGenerator {
    func generate(session: ProposalSession, ringSnapshot: UIImage?) -> UIImage
}

// SwiftUI 證書模板
struct CertificateTemplate: View {
    // 精美背景（漸層粉金色）
    // 頂部：「永恆之環」標題 + 裝飾線條
    // 中間：雙方暱稱 + 戒指渲染圖
    // 告白宣言（優美字體）
    // 底部：日期 + 浮水印
}
```

**證書規格：**
- 尺寸：1080 x 1920 px（適合 IG Story 分享）
- 格式：PNG（保留透明度選項）
- 儲存：自動存入相簿 + SwiftData 備份

---

## 7. UI/UX 設計系統

### 設計系統總覽

| 項目 | 規格 |
|------|------|
| **風格** | Soft UI Evolution — 柔和陰影、現代美學、微妙深度 |
| **模式** | 預設深色模式（適合夜間求婚場景），支援淺色模式 |
| **無障礙** | WCAG AA+ 對比度 4.5:1 以上 |

### 色彩系統

```swift
extension Color {
    // 主色調 - 浪漫紫羅蘭
    static let primary = Color(hex: "#7C3AED")       // 紫羅蘭
    static let primaryLight = Color(hex: "#A78BFA")  // 淺紫
    static let primaryDark = Color(hex: "#4C1D95")   // 深紫

    // 強調色 - 玫瑰金
    static let accent = Color(hex: "#F9A8D4")        // 玫瑰粉
    static let accentGold = Color(hex: "#D4AF37")    // 金色（戒指）

    // 背景
    static let backgroundDark = Color(hex: "#0F0A1A")   // 深夜紫黑
    static let backgroundLight = Color(hex: "#FAF5FF")  // 柔和淺紫

    // 文字
    static let textPrimary = Color.white.opacity(0.95)
    static let textSecondary = Color.white.opacity(0.7)

    // 特效
    static let heartbeatGlow = Color(hex: "#FF6B9D")    // 心跳發光
    static let particleGold = Color(hex: "#FFD700")     // 金色粒子
}
```

### 字型系統

```swift
extension Font {
    // 標題 - 優雅手寫風格（用於證書）
    static let displayLarge = Font.custom("GreatVibes-Regular", size: 48)

    // 正文 - 優雅襯線（iOS 使用 Georgia 替代）
    static let headingLarge = Font.system(size: 28, weight: .light, design: .serif)
    static let headingMedium = Font.system(size: 22, weight: .light, design: .serif)
    static let bodyLarge = Font.system(size: 17, weight: .regular, design: .serif)
    static let bodyMedium = Font.system(size: 15, weight: .regular, design: .default)
    static let caption = Font.system(size: 13, weight: .regular, design: .default)
}
```

### 間距系統

```swift
enum Spacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}
```

### 動畫規範

| 互動類型 | 時長 | 曲線 | 備註 |
|----------|------|------|------|
| 按鈕點擊 | 150ms | easeOut | 快速回饋 |
| 頁面轉場 | 300ms | easeInOut | 流暢過渡 |
| 心跳脈動 | 500ms | easeInOut | 循環動畫 |
| 戒指飛入 | 1500ms | spring | 彈性效果 |
| 粒子特效 | 2000ms | linear | 漸淡消失 |

### 觸覺回饋規範

| 情境 | 回饋類型 | 強度 |
|------|----------|------|
| 心跳（遠距離） | `.soft` | 0.4 |
| 心跳（近距離） | `.medium` | 0.8 |
| 戒指傳送 | `.rigid` | 1.0 |
| 戒指套上 | `.heavy` + 連續 | 1.0 |
| 按鈕點擊 | `.light` | 0.3 |

---

## 8. 畫面設計

### Host 流程

1. **首頁** - 3D 戒指預覽 + 「開始準備求婚」按鈕
2. **選擇戒指** - 三款戒指卡片（經典單鑽、奢華光環、簡約素圈）
3. **輸入資訊** - 暱稱 + 告白宣言輸入框
4. **QR Code 配對** - 顯示 QR Code + 等待連線

### 儀式畫面

5. **心跳同步** - 螢幕邊緣發光 + 心跳動畫 + 距離顯示
6. **準備傳送** - Host 向上滑動手勢引導
7. **戒指傳送** - 戒指飛出/飛入動畫
8. **AR 戴戒指** - 相機畫面 + 手部追蹤 + 粒子特效
9. **完成** - 截圖預覽 + 生成證書按鈕

### 證書設計

- 背景：漸層（淺紫 → 柔粉）
- 內容：標題、雙方暱稱、告白宣言、日期
- 尺寸：1080 x 1920 px（IG Story 相容）

---

## 9. App Clip 與配對流程

### App Clip 配置

**大小預估：**

| 資源 | 大小估算 |
|------|----------|
| 程式碼 + SwiftUI | ~2 MB |
| 3D 戒指模型 x3 | ~3 MB |
| 粒子特效資源 | ~1 MB |
| 字型資源 | ~0.5 MB |
| 其他資源 | ~1 MB |
| **總計** | **~7.5 MB** (< 10MB) |

### 配對流程

1. Host 產生 QR Code（URL: `https://eternalloop.app/join?session={sessionId}`）
2. Guest 掃描 → App Clip 啟動
3. Host 開始 MCNearbyServiceBrowser
4. Guest 開始 MCNearbyServiceAdvertiser
5. 建立 MCSession
6. 交換 NIDiscoveryToken
7. 啟動 NISession，開始 UWB 測距
8. 儀式開始

---

## 10. 錯誤處理與邊界情況

### 錯誤場景

| 場景 | 處理方式 |
|------|----------|
| UWB 不支援 | 顯示提示，改用手動模式 |
| 配對失敗 | 重試按鈕 + 故障排除提示 |
| 配對中斷 | 自動重連 3 次，失敗後提示 |
| AR 無法啟動 | 引導至設定頁開啟權限 |
| 手部偵測失敗 | 顯示引導提示，提供跳過選項 |

### 降級策略

1. **UWB 不可用** → 使用藍牙 RSSI 估算距離
2. **AR 手部追蹤失敗** → 降級為 2D 動畫
3. **連線中斷** → 自動重連 3 次

### 手動觸發備案

- 位置：右下角小愛心圖示
- 觸發：長按 3 秒
- 效果：強制進入「準備傳送」狀態

---

## 11. 測試策略

### 測試層級

| 層級 | 範圍 | 工具 |
|------|------|------|
| 單元測試 | 資料模型、狀態邏輯 | XCTest |
| 整合測試 | Manager 類別、資料流 | XCTest |
| UI 測試 | 畫面流程、互動 | XCUITest |
| 手動測試 | UWB、AR、雙機配對 | 實機測試 |

### 手動測試檢查清單

**雙機配對：**
- [ ] QR Code 掃描後 App Clip 正確啟動
- [ ] 配對在 5 秒內完成
- [ ] 配對失敗時顯示正確錯誤訊息

**UWB 測距：**
- [ ] 各距離段心跳頻率正確
- [ ] 手動觸發按鈕正常運作

**AR 戴戒指：**
- [ ] 戒指飛入動畫流暢
- [ ] 手部偵測正常
- [ ] 粒子特效正確顯示

**證書生成：**
- [ ] 內容正確
- [ ] 成功儲存至相簿

---

## 12. 決策記錄

| 決策 | 選項 | 原因 |
|------|------|------|
| MVP 範圍 | 旗艦版（完整 AR） | 完整儀式體驗 |
| App Clip 策略 | 包含完整 3D | 控制在 10MB 內 |
| 戒指款式 | 3 款經典款 | 涵蓋主流偏好 |
| AR 戴戒指 | 自動手部追蹤 | 最自然的體驗 |
| 隱藏模式 | 不實作 | 簡化開發 |
| 手動備案 | 長按愛心按鈕 | 可靠且不破壞儀式感 |
| 證書格式 | 精美圖片版 | 有紀念價值 |
| 心跳同步 | 漸進式 5 段 | 戲劇張力 |
| 粒子特效 | 金色光粒 + 愛心 | 優雅浪漫 |

---

*文件結束*
