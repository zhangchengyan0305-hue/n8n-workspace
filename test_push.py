import json
import urllib.request
import datetime

# 模擬一筆伺服器狀態數據（刻意將數值調高超過門檻，測試 Telegram 告警）
test_data = {
    "status": "warning",
    "diskUsage": 88.5,  # 超過 85% 門檻
    "memUsage": 92.0,   # 超過 90% 門檻
    "cpuUsage": 45.0,
    "timestamp": datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
}

url = "http://192.168.50.157:5678/webhook/server-status"

# 將字典轉為 JSON 字串並編碼為 bytes
data_bytes = json.dumps(test_data).encode('utf-8')

req = urllib.request.Request(
    url, 
    data=data_bytes, 
    headers={'Content-Type': 'application/json'}, 
    method='POST'
)

try:
    with urllib.request.urlopen(req) as response:
        result = response.read().decode('utf-8')
        print("✅ 測試資料推送成功！")
        print("伺服器回應：", result)
except Exception as e:
    print("❌ 推送失敗，錯誤訊息：", e)
