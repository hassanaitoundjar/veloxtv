# Remote Playlist Upload via Device ID & Key

Adding the ability for users to upload their playlists online via your website (using a Device ID/MAC and Key) is the industry standard for premium IPTV apps (like SmartIPTV, Flix IPTV, or IPTV Smarters Pro).

**Yes, this is completely possible to build.** Here is how we would architect it and the steps required to implement it.

## User Review Required

Because Android 11+ and iOS block apps from reading the real hardware MAC address for privacy reasons, **we cannot use the true MAC address**. 

Instead, we will generate a unique **Device ID** (which we can format to look like a MAC address if you prefer, e.g., `A1:B2:C3...`) and a secret **Device Key** the first time the user opens the app. This is how all modern IPTV apps handle this restriction.

> [!WARNING]
> This feature requires a backend database to store the playlists and act as a bridge between your Website and your TV app. Do you have a preference for the database? (e.g., Firebase, Supabase, or a custom MongoDB/PostgreSQL database attached to your Next.js site?)

## Proposed Architecture

This feature requires building three interconnected components:

### 1. The TV App (Flutter)
- **New Login Screen UI:** We will update the login screen to show a panel displaying:
  - "Upload your playlist at: `www.yourwebsite.com/upload`"
  - "Device ID: `XX:XX:XX:XX:XX`"
  - "Device Key: `12345`"
- **TV Detection:** The app will use the `device_info_plus` package to detect if the user is running an Android TV (checking for the `android.software.leanback` feature). The Device ID login screen will **only** appear if it's a TV. On mobile/tablets, it will show the standard login screen.
- **Preventing Trial Abuse (Anti-Uninstall):** To prevent users from deleting and reinstalling the app to reset their 7-day trial, we will **not** use a random UUID. Instead, we will use the hardware's `ANDROID_ID` (via the `android_id` package). The `ANDROID_ID` is permanently tied to the device and survives app uninstalls. It only resets if the user completely factory-wipes their TV, making trial abuse extremely difficult.
- **App Logic:** The app will fetch the permanent `ANDROID_ID` and save a Device Key. It will then ping your backend database to check if a user has uploaded an Xtream Codes credential or M3U link for that specific Device ID. Once it detects an uploaded playlist, it automatically logs the user in.

### 2. The Database (Backend)
- A simple database table named `devices` with the following columns:
  - `device_id` (String)
  - `device_key` (String)
  - `xtream_url` (String)
  - `xtream_username` (String)
  - `xtream_password` (String)
  - `status` (Active/Expired)

### 3. The Web Portal (Next.js)
- A new page on your website where users can type in their Device ID, Device Key, and their IPTV provider's URL/Username/Password. 
- When they click "Save", it writes to the database. The TV app immediately detects the change and logs them in.

## Open Questions

Before we start building, I need your input on the following:

> [!IMPORTANT]
> 1. **Backend Choice:** Do you already have a backend we can use (like Firebase), or would you like me to set up a free one like Supabase?
> 2. **Web Portal:** Do you want me to build the web portal inside one of your existing Next.js websites (like `iptvsmartproviders.com` or your VeloxTV site)?
> 3. **Format:** Do you want the "Device ID" to look like a MAC Address (e.g., `a1:b2:c3:d4:e5:f6`) or just a standard random ID?

If you approve of this architecture, let me know your answers to the open questions and we will begin Step 1: building the Flutter App interface and generation logic!
