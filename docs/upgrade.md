# Upgrading Immich

This guide outlines the steps required to upgrade your Immich instance running under Docker Compose on your macOS/OrbStack host.

> [!IMPORTANT]
> Immich is actively developed, and releases can occasionally introduce breaking changes. Always read the [Immich Release Notes](https://github.com/immich-app/immich/releases) before upgrading.

---

## Upgrade Steps

Follow these steps to upgrade your Immich instance:

### Step 1: Backup your Database
Before performing any upgrade, it is strongly recommended to back up your PostgreSQL database. Run the following command from the root of this repository:

```bash
docker compose exec -t database pg_dumpall -U postgres | gzip > ./backup.sql.gz
```
This will generate a compressed database dump `backup.sql.gz` in your repository folder.

### Step 2: Update the Version in `.env`
Open your local `.env` file and look for the `IMMICH_VERSION` variable:

```ini
IMMICH_VERSION=v3
```

You can change this to a specific tagged release (e.g., `v3.0.0`) to lock your deployment, or keep it as `v3` to fetch the latest stable minor/patch updates in the major version 3 family.

### Step 3: Pull New Images
Download the updated Docker images for Immich server and its dependencies:

```bash
docker compose pull
```

### Step 4: Recreate the Containers
Apply the new images and run migrations:

```bash
docker compose up -d --force-recreate
```

### Step 5: Verify the Deployment
Check the logs of the server to ensure migrations succeeded and the application starts properly:

```bash
docker compose logs -f immich-server
```

You can also navigate to **Administration > Server Stats** in the Web UI to confirm that all services are online and the version number has updated.

---

## Rollback Procedure (If something goes wrong)

If you encounter issues after upgrading and need to roll back:

1. **Stop the containers:**
   ```bash
   docker compose down
   ```
2. **Revert the version** in your `.env` file to the previously working tag.
3. **Restore the database:**
   If the database was modified and you need to restore the backup:
   ```bash
   # Start the database container only
   docker compose up -d database
   
   # Restore the backup (Warning: this overwrites current data)
   gunzip -c backup.sql.gz | docker compose exec -T database psql -U postgres -d immich
   ```
4. **Restart the stack:**
   ```bash
   docker compose up -d
   ```
