# Storage Management

This guide explains how to manage storage quotas for users (family and friends), monitor disk space, and safely migrate files if the path to your external HDD changes.

---

## 1. Setting and Expanding User Quotas

By default, newly created users in Immich have **unlimited storage** (they can consume all available space on your 22TB external HDD). To restrict each user to **2TB** and adjust it in the future, follow these steps:

### Setting a 2TB Limit
1. Log in to your Immich instance as an **Administrator**.
2. Go to **Administration** (shield icon in top-right) **> Users**.
3. Locate the user you want to restrict and click the **Edit** (pencil) icon next to their name.
4. Locate the **Storage Quota** setting.
5. Enter the limit in **GiB**:
   * For **2TB** (binary/GiB), enter `2048`.
   * For **2TB** (decimal/GB), enter `2000`.
6. Click **Save**.

Once a user reaches this limit, their mobile and web backups will be paused, and they will receive a notification that their storage is full.

### Expanding a User's Quota
If a user requests more space (e.g., expanding from 2TB to 3TB):
1. Navigate back to **Administration > Users** and click the **Edit** icon for the user.
2. Update the **Storage Quota** value (e.g., change `2048` to `3072` for 3TB).
3. Click **Save**.

> [!NOTE]
> Immich-generated metadata, system databases, video transcodes, and thumbnail caches are stored globally and do not count toward individual user quotas. Only original uploaded media files are counted.

---

## 2. Checking Disk and User Space Usage

* **Server Stats:** You can view overall disk utilization by going to **Administration > Server Stats**. This shows you a breakdown of the total drive capacity, how much free space remains on `/Volumes/Disco 22tb`, and how much space each user's library takes.
* **Database Stats:** PostgreSQL storage footprint can be monitored using standard database inspector tools or checked via Docker volume sizes.

---

## 3. Migrating Storage (Changing External HDD Path)

If your external HDD path changes (e.g., from `/Volumes/Disco 22tb` to `/Volumes/Immich Storage`), or if you migrate your data to an even larger drive, follow this migration procedure:

### Step 1: Stop Immich
Stop the running containers to prevent new writes during the transfer:
```bash
docker compose down
```

### Step 2: Copy data to the new drive (If changing hardware)
If you are moving files to a new external disk, copy the entire `immich` folder preserving permissions:
```bash
rsync -avh --progress "/Volumes/Disco 22tb/immich/" "/Volumes/New Drive Name/immich/"
```

### Step 3: Update the Environment Variable
Open your local `.env` file and update the `EXTERNAL_DISK_PATH` variable:

```ini
# Before
EXTERNAL_DISK_PATH=/Volumes/Disco 22tb

# After
EXTERNAL_DISK_PATH=/Volumes/New Drive Name
```

Because `UPLOAD_LOCATION` and `DB_DATA_LOCATION` are relative to `EXTERNAL_DISK_PATH`, both your photo library and database paths will automatically adjust!

### Step 4: Restart Immich
Re-initialize the Docker containers:
```bash
docker compose up -d
```
All of your users, photos, and configurations will remain perfectly intact.
