import subprocess
import time
import os
import re
import sys

services = {
    "n8n": "5678",
    "portainer": "9000",
    "nextcloud": "8080",
    "openhands": "3000",
    "uptime": "3001"
}

links = {}
log_path = "/home/hugochang/n8n-workspace/tunnel_runner.log"

def log_msg(msg):
    timestamp = time.strftime("%Y-%m-%d %H:%M:%S")
    line = f"[{timestamp}] {msg}"
    print(line)
    sys.stdout.flush()
    with open(log_path, "a") as f:
        f.write(line + "\n")

def update_nextcloud_trusted(domain):
    config_path = "/var/lib/docker/volumes/nextcloud_data/_data/config/config.php"
    try:
        with open(config_path, "r") as f:
            content = f.read()
        if domain not in content:
            lines = content.splitlines()
            new_lines = []
            in_trusted = False
            for line in lines:
                if "'trusted_domains'" in line:
                    in_trusted = True
                    new_lines.append(line)
                    continue
                if in_trusted and ")," in line:
                    new_lines.append(f"  4 => '{domain}',")
                    in_trusted = False
                new_lines.append(line)
            with open(config_path, "w") as f:
                f.write("\n".join(new_lines) + "\n")
            subprocess.run(["sudo", "docker", "restart", "nextcloud"])
    except Exception as e:
        log_msg(f"Failed to update nextcloud config: {e}")

def get_tunnel_link(port):
    t_log = f"/tmp/tunnel_{port}.log"
    if os.path.exists(t_log):
        os.remove(t_log)
    
    cmd = f"cloudflared tunnel --url http://localhost:{port} > {t_log} 2>&1"
    proc = subprocess.Popen(cmd, shell=True)
    
    start_time = time.time()
    link = None
    while time.time() - start_time < 20:
        if os.path.exists(t_log):
            with open(t_log, "r") as f:
                content = f.read()
                match = re.search(r"https://[a-zA-Z0-9.-]+\.trycloudflare\.com", content)
                if match:
                    link = match.group(0)
                    break
                if "429" in content or "failed with status 429" in content:
                    break
        time.sleep(1)
        
    proc.terminate()
    try:
        proc.wait(timeout=2)
    except:
        proc.kill()
    return link

log_msg("Starting automated hourly/scheduled tunnel fetching daemon...")
while len(links) < len(services):
    for name, port in list(services.items()):
        if name in links:
            continue
        log_msg(f"Trying to get tunnel for {name} (port {port})...")
        link = get_tunnel_link(port)
        if link:
            log_msg(f"SUCCESS: {name} -> {link}")
            links[name] = link
            if name == "nextcloud":
                update_nextcloud_trusted(link.replace("https://", ""))
            time.sleep(15)
        else:
            log_msg(f"RATE LIMITED (429) or failed for {name}. Waiting 5 minutes...")
            time.sleep(300)

log_msg("ALL 5 LINKS ACQUIRED SUCCESSFULLY!")
final_output = ""
for name, link in links.items():
    final_output += f"{name}: {link}\n"
log_msg(final_output)

with open("/home/hugochang/n8n-workspace/final_links.txt", "w") as f:
    f.write(final_output)
