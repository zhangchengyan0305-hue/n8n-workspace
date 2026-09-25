#!/bin/bash

# 進入工作區目錄
cd "$(dirname "$0")"

echo "🔄 1. 正在從 n8n 自動匯出最新工作流..."
mkdir -p workflows/system workflows/integrations

# 透過明確的工作流 ID 匯出
sudo docker exec -u node n8n n8n export:workflow --id=7bZ9MTTdzcfrzjrk --output=/home/node/.n8n/server.json 2>/dev/null || true
sudo docker cp n8n:/home/node/.n8n/server.json ./workflows/system/server-sentinel.json 2>/dev/null || true

sudo docker exec -u node n8n n8n export:workflow --id=sUTcL357cQ9nAamR --output=/home/node/.n8n/trading.json 2>/dev/null || true
sudo docker cp n8n:/home/node/.n8n/trading.json ./workflows/integrations/trading-learning-card.json 2>/dev/null || true

echo "🔍 2. 檢查 Git 專案變更..."
if [ -z "$(git status --porcelain)" ]; then
    echo "✅ 目前沒有任何變更，無需 Commit。"
    exit 0
fi

git status -s

COMMIT_MSG="$1"
if [ -z "$COMMIT_MSG" ]; then
    TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
    COMMIT_MSG="auto-backup: sync workflows and configs ($TIMESTAMP)"
fi

echo "🚀 3. 推送到 GitHub..."
git add .
git commit -m "$COMMIT_MSG"
git push

echo "🎉 同步完成！"
EOF

chmod +x /home/hugochang/n8n-workspace/git-auto-sync.sh
