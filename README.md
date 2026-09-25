# n8n Automation Workspace & Server Setup

本專案記錄了在 Ubuntu 伺服器上，從零建置 Docker 環境、Portainer 網頁管理介面，到透過 Docker Compose 部署 n8n 自動化工作流的完整架構與設定檔。

---

## 🛠️ 第一階段：Ubuntu 伺服器基礎環境建置 (Infrastructure)

在啟動 n8n 之前，系統已完成了 Docker 引擎與 Portainer 網頁管理工具的部署：

### 1. 安裝 Docker 核心引擎
```bash
# 更新套件並安裝 Docker
sudo apt update && sudo apt install -y docker.io

# 設定 Docker 開機自動啟動並立即執行
sudo systemctl enable --now docker

# 將當前帳號加入 docker 群組（免 sudo 權限）
sudo usermod -aG docker $USER
```

### 2. 部署 Portainer 網頁管理介面
```bash
# 建立 Portainer 資料持久化 Volume
sudo docker volume create portainer_data

# 啟動 Portainer 容器
sudo docker run -d \
  -p 8000:8000 \
  -p 9443:9443 \
  --name portainer \
  --restart=always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  portainer/portainer-ce:latest
```
- **Portainer 管理後台：** `https://<你的Ubuntu IP>:9443`

---

## 🚀 第二階段：n8n 部署與工作區管理

本專案採用 **環境變數與敏感資訊抽離 (Decoupled Env Config)** 的架構維護，避免 API Key 外洩。

### 1. 檔案結構說明
```plaintext
n8n-workspace/
├── docker-compose.yml  # n8n 服務定義檔
├── .env                # 實際環境變數與私密 API Key（已加入 .gitignore，不推送到 Git）
├── .env.example        # 環境變數範本檔（提交至 GitHub 供參考）
├── .gitignore          # 排除敏感檔案與日誌
└── README.md           # 伺服器建置與部署說明文件
```

### 2. 快速部署與還原步驟

1. **複製並設定環境變數：**
   ```bash
   cp .env.example .env
   nano .env
   ```
   請根據實際環境填入 `N8N_HOST`、`WEBHOOK_URL` 以及相關 API Key。

2. **啟動 n8n 服務：**
   可以在本機透過 Docker Compose 啟動，或將 `docker-compose.yml` 內容貼入 Portainer Stack 部署：
   ```bash
   docker compose up -d
   ```

3. **存取 n8n 儀表板：**
   開啟瀏覽器訪問：`http://<你的Ubuntu IP>:5678`

---

## 🔐 安全性與版控規範

- **敏感資訊防護：** 真正的敏感參數（如 `OPENAI_API_KEY`、`LINE_CHANNEL_SECRET`、ngrok URL）皆統一放在 `.env` 中，絕不寫死在 `docker-compose.yml` 或提交至 GitHub。
- **備份機制：** n8n 的資料（Credentials 與 Workflows）皆透過 Docker Volume (`n8n_data`) 儲存在宿主機中進行持久化備份。
