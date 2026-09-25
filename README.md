# n8n Automation Workspace

這是基於 Docker Compose 建立的 n8n 自動化流程部署專案。

## 🚀 快速啟動步驟

1. **複製環境變數設定檔：**
   ```bash
   cp .env.example .env
   ```
   並根據實際環境修改 `.env` 內的參數（如 `N8N_HOST`、`WEBHOOK_URL` 等）。

2. **啟動 n8n 容器：**
   ```bash
   docker compose up -d
   ```

3. **訪問 n8n 編輯器：**
   打開瀏覽器訪問：`http://192.168.50.157:5678/` (或對應設定的網址)。

## 📁 專案結構
- `docker-compose.yml` : Docker Compose 服務配置檔
- `.env` : 實際環境變數（已加入 `.gitignore` 避免外洩）
- `.env.example` : 環境變數範本檔
- `.gitignore` : Git 忽略清單
