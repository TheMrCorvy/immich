# Mobile App Connection & Auto-Backup

This guide shows you how to connect your iOS or Android mobile device to your Immich instance and set up automated, hands-off background backups.

---

## 1. Download the Immich Mobile App

Search for **Immich** in your device's official app store:
* **iOS:** [App Store](https://apps.apple.com/app/immich/id1613974171)
* **Android:** [Google Play Store](https://play.google.com/store/apps/details?id=app.alextran.immich)

> [!IMPORTANT]
> The mobile app version should match the server version. If you update the server (e.g., using `v3`), make sure the mobile app is also updated to the latest version to prevent connection compatibility errors.

---

## 2. Connecting to Your Instance

To log in, follow these steps:

1. Open the **Immich** app on your device.
2. In the **Server Endpoint URL** field, enter:
   ```text
   https://immich.chaldea.foundation
   ```
   *(Note: The app will automatically query the `/api` endpoint internally. You do not need to add `/api` to the URL unless prompted by older app versions).*
3. Tap **Next**.
4. Enter the login credentials provided by the administrator:
   * **Email Address**
   * **Password**
5. Tap **Login**.

---

## 3. Configuring Automatic Photo/Video Backups

Immich supports automatic background uploads. Setting it up correctly ensures your photos back up silently without draining battery or mobile data.

### Step 1: Grant Permissions
Upon logging in, the app will request permission to access your photo library.
* **iOS:** Select **Allow Access to All Photos**.
* **Android:** Select **Allow** when prompted for files/media permissions.

### Step 2: Enable Auto-Backup
1. If the app displays an "Enable Backup" setup wizard on first launch, follow it.
2. If not, go to the app's settings (tap your profile icon in the top-right corner) and select **App Settings > Backup Settings**.
3. Toggle **Enable Backup** to **On**.

### Step 3: Configure Backup Settings (Recommended)
Customize your backups to match your needs:

* **Select Albums:** Choose which folders to back up. Usually, you want to toggle the **Camera Roll** or **DCIM** folder.
* **Back Up Only on WiFi:** Enable this option to avoid consuming your cellular mobile data plan.
* **Back Up Only While Charging:** Enable this if you want backup jobs to only run when your phone is plugged in (saves battery).
* **Background Backup:**
  * **iOS:** Enable **Background App Refresh** in your iOS system settings for Immich. Note that iOS limits background execution time. For large initial backups, keep the Immich app open in the foreground with your screen auto-lock set to "Never" until finished.
  * **Android:** Turn off **Battery Optimization** for the Immich app. This allows Android to keep the Immich background worker active for seamless backup sync.
