# Self-Hosted Immich on macOS Sequoia (OrbStack)

This repository contains the configuration, environment setup, and Kubernetes boilerplate to deploy **Immich**—a high-performance, self-hosted alternative to Google Photos—on an Intel-based Mac Mini (2018) running macOS Sequoia with OrbStack.

---

## Architecture Overview

* **Host Platform:** Mac Mini (2018, Intel i5, macOS Sequoia)
* **Container Runtime:** OrbStack (efficient Docker Desktop alternative)
* **Primary Storage:** 22TB External HDD (`/Volumes/Disco 22tb`)
* **Exposure Model:** Pangolin Reverse Proxy + Newt Tunnel (mapping local port `2283` to `https://immich.chaldea.foundation`)
* **AI/Machine Learning:** Disabled (containers and model cache commented out to save CPU/RAM)
* **Telemetry:** Disabled/None
* **Database:** PostgreSQL (with `pgvector` extension) running inside the Docker stack with data directories stored directly on the 22TB external HDD alongside your media.

---

## Directory Structure

```text
├── .env.example              # Template for environment configuration
├── .gitignore                # Prevents committing secrets and data folders
├── docker-compose.yml        # Docker compose configuration (AI-disabled, HDD-tuned)
├── docs/                     # Guides and configurations
│   ├── upgrade.md            # Upgrading and database backup guide
│   ├── user-setup.md         # Creating administrator and family/friend accounts
│   ├── storage-management.md # Allocating space, managing 2TB quotas, and drive migration
│   └── mobile-app-connection.md # Connecting iOS/Android apps with auto-backup
└── kubernetes/               # Future-proof Kubernetes manifests (boilerplate)
    ├── namespace.yaml
    ├── configmap.yaml
    ├── secrets.yaml
    ├── storage.yaml
    ├── postgres.yaml
    ├── redis.yaml
    ├── immich-server.yaml
    └── ingress.yaml
```

---

## Getting Started (Docker Compose with OrbStack)

### Step 1: Clone and Configure Environment
1. Copy the example environment file to `.env`:
   ```bash
   cp .env.example .env
   ```
2. Open `.env` in a text editor.
3. Configure the variables:
   * **`EXTERNAL_DISK_PATH`**: Keep as `/Volumes/Disco 22tb` (or change if your external disk mount path shifts).
   * **`IMMICH_PORT`**: Port number bound on your host (default is `2283`).
   * **`IMMICH_BIND_ADDRESS`**: The host address to bind the port to. Default is `127.0.0.1` (localhost only) because you are exposing it through Pangolin/Newt. If you want local network clients to connect directly to the Mac Mini IP, change this to `0.0.0.0`.
   * **`DB_PASSWORD`**: Replace with a secure, random database password.

### Step 2: Start the Containers
In your terminal, run the following command to start Immich in detached background mode:
```bash
docker compose up -d
```
OrbStack will download the images, initialize PostgreSQL and Valkey/Redis, mount the external drive paths, and launch the Immich server.

### Step 3: Complete Web UI Setup
1. Open your browser and go to `http://127.0.0.1:2283` (or your public domain `https://immich.chaldea.foundation` once the reverse proxy is active).
2. Register the initial Owner/Administrator account.
3. Disable Machine Learning in the Web UI:
   * Go to **Administration > Settings > Machine Learning Settings**.
   * Toggle **Enable machine learning** to **Off** and click **Save**.

---

## Detailed Documentation Guides

Please refer to the following Markdown files for specific management topics:

1. 📂 [Upgrading Immich](docs/upgrade.md) — Learn how to update Immich, back up the database, and rollback if needed.
2. 📂 [User Setup](docs/user-setup.md) — Step-by-step instructions on registering family and friends.
3. 📂 [Storage Management](docs/storage-management.md) — How to enforce a 2TB limit, expand quotas, and handle external HDD migration.
4. 📂 [Mobile App Connection](docs/mobile-app-connection.md) — Guide on connecting mobile apps to back up photos automatically.

---

## Kubernetes Deployment (Future-Proof Boilerplate)

The `kubernetes/` folder contains Kubernetes manifests optimized for this setup using `hostPath` volumes mapping your macOS external drive `/Volumes/Disco 22tb`.

To deploy them in the future:
```bash
kubectl apply -f kubernetes/namespace.yaml
kubectl apply -f kubernetes/
```
These manifests will deploy Postgres (HDD-optimized), Valkey/Redis, Ingress configuration with large payload sizes, and the core Immich server in the `immich` namespace.
