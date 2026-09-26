# n8n Automation Workspace

Production-ready Docker environment for n8n automation workflows, managed with Portainer and backed up via automated Git synchronization.

## System Architecture

| Component | Port | Access URL | Description |
| :--- | :--- | :--- | :--- |
| **n8n** | `5678` | `http://<SERVER_IP>:5678` | Workflow automation engine |
| **Portainer** | `9443` | `https://<SERVER_IP>:9443` | Web-based container management UI |

## Directory Layout

```text
n8n-workspace/
├── docker-compose.yml       # Docker service specification
├── git-auto-sync.sh        # Cron script for automated workflow export & backup
├── .env.example             # Template for required environment variables
├── .gitignore               # Excludes secrets, logs, and sensitive data
└── workflows/
    ├── system/              # Infrastructure and server monitoring
    └── integrations/        # External API and third-party integrations
```

## Workflows Index

| Workflow | Category | File | Description |
| :--- | :--- | :--- | :--- |
| Server Sentinel | system | [server-sentinel.json](workflows/system/server-sentinel.json) | Monitors CPU, RAM, and disk utilization; dispatches alert notifications upon threshold breach |
| Trading Card Service | integrations | [trading-learning-card.json](workflows/integrations/trading-learning-card.json) | Processes and broadcasts quantitative trading learning cards via automated scheduled triggers |

## Deployment & Setup

### 1. Infrastructure Initialization
Install the Docker engine and deploy Portainer on Ubuntu:

```bash
# Install Docker
sudo apt update && sudo apt install -y docker.io
sudo systemctl enable --now docker
sudo usermod -aG docker $USER

# Deploy Portainer UI
sudo docker volume create portainer_data
sudo docker run -d \
  -p 8000:8000 \
  -p 9443:9443 \
  --name portainer \
  --restart=always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  portainer/portainer-ce:latest
```

### 2. Launching n8n

```bash
# Clone repository and configure environment variables
git clone https://github.com/<YOUR_USERNAME>/n8n-workspace.git
cd n8n-workspace
cp .env.example .env

# Edit .env with your specific host domains and secrets
nano .env

# Start service container
sudo docker compose up -d
```

### 3. Importing Workflows
1. Open the n8n dashboard (`http://<SERVER_IP>:5678`).
2. Go to **Workflows** → **Add Workflow**.
3. Click the `...` menu in the top-right corner → Select **Import from JSON**.
4. Choose the target `.json` file from the `workflows/` directory.

## Automated Backup Sync
The included `git-auto-sync.sh` script exports active workflows directly from the n8n container and commits updated JSON files to GitHub.

Make the script executable:
```bash
chmod +x git-auto-sync.sh
```

Execute manual sync:
```bash
./git-auto-sync.sh "chore: backup updated workflows"
```

## Security & Environment Variable Decoupling

- **Secret Isolation**: Sensitive credentials (API tokens, database credentials, webhook URLs) are stored exclusively in `.env` and excluded from source control via `.gitignore`.
- **Sanitized Workflows**: Exported JSON files in `workflows/` contain workflow structures and logic while stripping out active authentication tokens.
