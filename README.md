# n8n Automation Workspace & Server Setup

本專案記錄了在 Ubuntu 伺服器上，從零建置 Docker 環境、Portainer 網頁管理介面，到透過 Docker Compose 部署 n8n 自動化工作流的完整架構與設定檔。

---

## 🛠️ 伺服器基礎環境建置 (Infrastructure)

- **Docker 核心引擎**：運行容器化服務
- **Portainer 網頁管理介面**：`https://<YOUR_SEREVR_IP>:9443`
- **n8n 自動化平台**：`http://<YOUR_SERVER_IP>:5678`

---

## 🔄 自動化工作流目錄 (Workflows Index)

本專案所有的自動化工作流皆已導出並透過 Git 進行版本控制，包含以下模組：

| 工作流名稱 | 分類 | JSON 檔案連結 | 功能說明 |
| :--- | :--- | :--- | :--- |
| **伺服器健康度與硬碟預警器** | 系統維護 (`system`) | [`server-sentinel.json`](./workflows/system/server-sentinel.json) | 定期監控 CPU、RAM 與硬碟，異常時發送告警 |
| **量化交易學習小卡** | 服務串接 (`integrations`) | [`trading-learning-card.json`](./workflows/integrations/trading-learning-card.json) | 定期推播與處理量化交易知識小卡內容 |

### 📥 如何將 Workflows 匯入到新的 n8n 實例：
1. 登入 n8n 儀表板，點選 **Workflows** -> **Add Workflow**。
2. 點擊右上角 `...` 選單 -> 選擇 **Import from JSON**。
3. 選擇 `workflows/` 對應目錄下的 `.json` 檔案即可完成還原。

---

## 🔐 安全性規範
- 敏感參數（如 API Key、Token）皆統一存放於 `.env`，已於 `.gitignore` 中排除，公開儲存庫僅保留 `.env.example` 範本與已去除敏感憑證的 JSON 工作流。
