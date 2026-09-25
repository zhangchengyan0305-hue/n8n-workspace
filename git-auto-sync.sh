#!/bin/bash

# 進入工作區目錄
cd "$(dirname "$0")"

# 1. 自動從 n8n 匯出最新工作流
mkdir -p workflows/system workflows/integrations
sudo docker exec -u node n8n n8n export:workflow --id=7bZ9MTTdzcfrzjrk --output=/home/node/.n8n/server.json 2>/dev/null || true
sudo docker cp n8n:/home/node/.n8n/server.json ./workflows/system/server-sentinel.json 2>/dev/null || true

sudo docker exec -u node n8n n8n export:workflow --id=sUTcL357cQ9nAamR --output=/home/node/.n8n/trading.json 2>/dev/null || true
sudo docker cp n8n:/home/node/.n8n/trading.json ./workflows/integrations/trading-learning-card.json 2>/dev/null || true

# 2. 🚨 關鍵防護：檢查是否有「真正的變更」
# 如果 Git 狀態是乾淨的，直接安靜退出，不產生任何 Commit！
if [ -z "$(git status --porcelain)" ]; then
    exit 0
fi

# 3. 如果有變更，智慧判斷修改內容並生成語意化 Commit 訊息
CHANGES=$(git status -s)
COMMIT_MSG="$1"

if [ -z "$COMMIT_MSG" ]; then
    if echo "$CHANGES" | grep -q "workflows/"; then
        COMMIT_MSG="feat(workflow): update n8n workflow JSON configurations"
    elif echo "$CHANGES" | grep -q "docker-compose"; then
        COMMIT_MSG="chore(infra): update docker-compose infrastructure settings"
    else
        COMMIT_MSG="chore: update workspace configuration files"
    fi
fi

# 4. 執行提交與推送
git add .
git commit -m "$COMMIT_MSG"
git push
