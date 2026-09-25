#!/bin/bash

# 進入 n8n 工作區目錄
cd "$(dirname "$0")"

echo "=== 正在檢查 n8n-workspace 專案變更狀況 ==="

# 檢查是否有任何未提交的變更
if [[ -z $(git status -s) ]]; then
    echo "👍 目前沒有發現任何需要備份的變更。"
    exit 0
fi

# 顯示目前變更摘要
echo "--- 偵測到以下變更 ---"
git status -s
echo "------------------------"

# 將所有允許的變更加入暫存區（.gitignore 會自動排除 .env 和 n8n_data 等敏感/大型檔案）
git add .

# 決定 Commit 訊息
if [ -n "$1" ]; then
    # 如果執行腳本時有帶參數，就用帶入的參數作為 commit 訊息
    COMMIT_MSG="$1"
else
    # 自動偵測修改了什麼來組合簡要訊息
    TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
    CHANGED_FILES=$(git diff --cached --name-only | tr '\n' ', ')
    COMMIT_MSG="chore(auto-backup): update configurations and workflows at $TIMESTAMP [$CHANGED_FILES]"
fi

# 執行 Git Commit
git commit -m "$COMMIT_MSG"

if [ $? -eq 0 ]; then
    echo "✅ Git Commit 成功完成！"
    
    # 推送到 GitHub
    echo "🚀 正在推送到 GitHub (origin main)..."
    git push origin main
    
    if [ $? -eq 0 ]; then
        echo "🎉 成功推送到 GitHub 備份完成！"
    else
        echo "❌ 推送到 GitHub 失敗，請檢查網路連線或 Token 狀態。"
        exit 1
    fi
else
    echo "❌ Git Commit 失敗。"
    exit 1
fi
