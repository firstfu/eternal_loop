# 3D 戒指模型資源

本目錄用於存放 AR 體驗中使用的 3D 戒指模型（USDZ 格式）。

## 需要的模型檔案

| 檔案名稱 | 戒指類型 | 說明 |
|---------|---------|------|
| `ring_classic.usdz` | 經典單鑽 | 簡約的單顆鑽石戒指 |
| `ring_halo.usdz` | 奢華光環 | 主石周圍環繞小鑽石 |
| `ring_minimal.usdz` | 簡約素圈 | 無鑽石的素面戒指 |

## 免費模型下載來源

### 1. Poly Pizza (CC0/CC-BY)
- 網址: https://poly.pizza/search/rings
- 推薦模型:
  - "Diamond ring" by Poly by Google (CC-BY 3.0)
  - "Ring" by Zsky (CC-BY 3.0)

### 2. Sketchfab (CC Attribution)
- 網址: https://sketchfab.com/tags/diamond-ring
- 推薦模型:
  - "USDZ Ring AR" by rajaroy52525 (CC Attribution)
  - 搜尋 "engagement ring" 並篩選可下載的模型

### 3. 3DModels.org (Royalty Free)
- Wedding Ring: https://3dmodels.org/3d-models/wedding-ring/
- Diamond Ring: https://3dmodels.org/3d-models/diamond-ring/

## 格式轉換

大多數免費模型提供 GLB/GLTF/FBX 格式，需要轉換為 USDZ。

### 方法 1: Reality Converter (推薦)
1. 從 Mac App Store 下載 [Reality Converter](https://apps.apple.com/app/reality-converter/id1465718987)
2. 開啟應用程式
3. 拖拽 GLB/GLTF/FBX 檔案到視窗
4. 點擊 File → Export → USDZ
5. 儲存到此目錄

### 方法 2: 命令列工具
```bash
# 安裝 Xcode Command Line Tools (如果尚未安裝)
xcode-select --install

# 使用 usdzconvert (需要下載 USD Python Tools)
# https://developer.apple.com/download/all/?q=reality%20converter
usdzconvert input.gltf output.usdz
```

### 方法 3: 線上轉換
- https://products.groupdocs.app/conversion/gltf-to-usdz
- https://imagetostl.com/convert/file/gltf/to/usdz

## 模型優化建議

1. **檔案大小**: 每個模型建議 < 5MB，以確保 App Clip 大小限制
2. **多邊形數**: 建議 < 50,000 面，以確保 AR 效能
3. **材質**: 使用 PBR 材質以獲得最佳視覺效果
4. **縮放**: 模型應以公尺為單位，戒指直徑約 0.02m (2cm)

## 授權聲明

使用 CC-BY 授權的模型時，請在 App 的關於頁面加入作者署名：
```
3D Models:
- "Diamond ring" by Poly by Google (CC-BY 3.0)
- [其他模型...]
```

## 測試模型

如果暫時沒有模型，App 會使用程式碼產生的簡易圓環作為替代。
