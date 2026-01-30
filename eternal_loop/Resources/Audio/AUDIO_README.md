# 音樂資源

本目錄用於存放背景音樂和音效檔案。

## 需要的音樂檔案

| 檔案名稱 | 用途 | 建議長度 |
|---------|------|---------|
| `romantic_piano.mp3` | 儀式進行中的浪漫背景音樂 | 3-5 分鐘 (循環播放) |
| `elegant_strings.mp3` | 優雅弦樂風格背景音樂 | 3-5 分鐘 (循環播放) |
| `celebration.mp3` | 戒指交換完成後的慶祝音樂 | 1-2 分鐘 |

## 需要的音效檔案

| 檔案名稱 | 用途 | 建議長度 |
|---------|------|---------|
| `heartbeat.wav` | 心跳音效 | 1-2 秒 |
| `ring_appear.wav` | 戒指出現時的音效 | 1-2 秒 |
| `success.wav` | 成功音效 | 1 秒 |
| `connection.wav` | 裝置連接成功音效 | 1 秒 |

## 免費音樂下載來源

### 1. Pixabay Music (完全免費商用)
- 網址: https://pixabay.com/music/
- 搜尋: "romantic piano", "wedding", "love"
- 授權: Pixabay License (免費商用，無需署名)
- 推薦曲目:
  - "Romantic Piano Background"
  - "Wedding Love Story"
  - "Emotional Piano"

### 2. Free Music Archive (CC 授權)
- 網址: https://freemusicarchive.org/
- 搜尋: "piano", "romantic", "wedding"
- 授權: 各種 CC 授權，請注意查看

### 3. Mixkit (免費商用)
- 網址: https://mixkit.co/free-stock-music/
- 類別: "Romantic", "Cinematic"
- 授權: Mixkit License (免費商用)

### 4. Zapsplat (免費音效)
- 網址: https://www.zapsplat.com/
- 搜尋: "heartbeat", "magic", "success"
- 授權: 免費帳號可商用（需署名）

### 5. Freesound (CC 授權)
- 網址: https://freesound.org/
- 搜尋: "heartbeat", "ring", "chime"
- 授權: 各種 CC 授權

## 音檔格式轉換

### 使用 FFmpeg
```bash
# 安裝 FFmpeg (macOS)
brew install ffmpeg

# 轉換為 MP3 (背景音樂)
ffmpeg -i input.wav -b:a 192k output.mp3

# 轉換為 WAV (音效)
ffmpeg -i input.mp3 -acodec pcm_s16le -ar 44100 output.wav
```

### 使用線上工具
- https://cloudconvert.com/
- https://audio.online-convert.com/

## 音檔優化建議

1. **檔案大小**:
   - 背景音樂 < 3MB (使用 128-192kbps)
   - 音效 < 500KB

2. **取樣率**: 44100 Hz

3. **位元深度**: 16-bit

4. **循環點**: 確保背景音樂的開頭和結尾能無縫銜接

## 授權聲明

如果使用 CC-BY 授權的音樂，請在 App 的「致謝與授權」頁面加入作者署名：

```
Music:
- "Track Name" by Artist Name (CC-BY 4.0)
```

## 備用方案

如果沒有自訂音樂檔案，App 會使用系統內建音效作為替代：
- 背景音樂: 無聲 (可在設定中開啟/關閉)
- 音效: 系統音效
