# Setting Up Users

This guide explains how to set up the initial administrator account and add new users (family and friends) to your Immich instance.

---

## 1. Initial Administrator Setup

When you start Immich for the first time, the database is empty, and there are no users. The first person to sign up through the web interface will automatically become the **Owner/Administrator** of the instance.

1. Open your web browser and navigate to your Immich instance:
   * **Local Access:** `http://127.0.0.1:2283` (or the custom port you set in `.env`)
   * **Remote Access:** `https://immich.chaldea.foundation` (if your reverse proxy is active)
2. Click **Getting Started**.
3. Create your admin account by entering:
   * **Email Address**
   * **Password** (make it strong and secure)
   * **First Name** and **Last Name**
4. Click **Sign Up** to create the administrator account and log in.

---

## 2. Adding Family & Friends (New Users)

Once the administrator account is created, only administrators can register or invite new users. There are two primary ways to add new users: **Direct Creation** or **Email Invites**.

### Option A: Direct User Creation (Recommended for family/friends)
If you already know the login details you want to assign them:

1. Click on the **Administration** button in the top-right corner of the web interface (shield/cogs icon).
2. Select the **Users** tab on the left sidebar.
3. Click **Create User** in the top-right.
4. Fill in the user details:
   * **Email**
   * **Password** (provide a temporary password they can change later)
   * **First Name** & **Last Name**
5. (Optional) Check the **Can Create Shared Links** option if you want them to be able to share photos with non-registered guests.
6. Click **Create**.
7. Share the email and temporary password with the user.

### Option B: Email Invites (Requires SMTP setup)
If you configure an email server (SMTP) in the Immich settings under **Administration > Settings > SMTP Settings**:

1. In the **Users** tab, click the **Invite User** button.
2. Enter the user's email address.
3. Immich will send them a link to set up their own account and password.

---

## 3. Disabling Machine Learning (AI) for All Users
To ensure the Mac Mini's resources are conserved and that no face/smart scanning is performed (as requested):

1. Log in as an **Administrator**.
2. Go to **Administration > Settings**.
3. Click on **Machine Learning Settings** in the menu.
4. Toggle **Enable machine learning** to **Off**.
5. Click **Save**.
6. This will stop the server from queuing machine learning tasks when users upload new photos or videos.
