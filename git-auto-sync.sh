#!/bin/bash

# 進入工作區目錄
cd "$(dirname "$0")"

echo "🔍 正在檢查 n8n-workspace 專案變更..."

if [ -z "$(git status --porcelain)" ]; then
    echo "✅ 目前沒有任何變更，無需 Commit。"
    exit 0
fi

echo "--- 偵測到以下變更 ---"
git status -s
echo "------------------------"

COMMIT_MSG="$1"
if [ -z "$COMMIT_MSG" ]; then
    TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
    COMMIT_MSG="auto-backup: sync workflows and configs ($TIMESTAMP)"
fi

echo "🚀 正在將更動加入暫存並推送到 GitHub..."
git add .
git commit -m "$COMMIT_MSG"
git push

echo "🎉 成功推送到 GitHub 備份完成！"
EOF

chmod +x /home/hugochang/n8n-workspace/git-auto-sync.sh
