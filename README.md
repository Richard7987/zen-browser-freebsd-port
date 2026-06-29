# zen-browser-freebsd-port

FreeBSD port for [Zen Browser](https://zen-browser.app) — a Firefox-based browser focused on privacy and productivity — running via the Linux compatibility layer (`linux_base-rl9`).

This port automates everything needed to get Zen Browser fully working on FreeBSD, including:

- Stub libraries for the Linux compat layer (libmfx, libzvbi, libsoxr, AMR codecs, SVT-AV1) required by the bundled FFmpeg
- `libnotify` from Rocky Linux 9 for system notifications via DBus
- A wrapper script that auto-detects Widevine CDM, configures PulseAudio, GTK theme, and DBus session automatically

---

## System Requirements

- FreeBSD 13.0-RELEASE or later (tested on 15.1-RELEASE)
- Linux compatibility layer enabled (see Prerequisites)
- PulseAudio (`audio/pulseaudio`)
- X11 session

---

## Prerequisites

The Linux compatibility layer must be enabled once before installing the port.

**1. Enable it in `/etc/rc.conf`:**

```sh
doas sysrc linux_enable="YES"
```

**2. Start the service (or reboot):**

```sh
doas service linux start
```

That's it — `linux_base-rl9` will be pulled in automatically as a port dependency.

---

## Installation

Clone this repo into your ports tree and install:

```sh
git clone https://github.com/Richard7987/zen-browser-freebsd-port.git /usr/ports/www/zen-browser
cd /usr/ports/www/zen-browser
doas make install clean
```

Or copy the directory manually into an existing ports tree overlay.

The ldconfig cache for the Linux compat layer is updated automatically after installation.

---

## Audio/Video Codec Support (AAC, H264)

Spotify, Crunchyroll (free tier), and other sites that serve AAC audio or H264 video work out of the box. The port installs stub libraries for `libavcodec.so.59`'s dependencies (`libmfx`, `libzvbi`, `libSvtAv1Enc`, AMR codecs, etc.) into `/compat/linux/usr/lib64/` so the ldconfig cache makes them visible to all Linux processes — including Firefox's Utility process, which decodes media with a clean environment and cannot use `LD_LIBRARY_PATH`.

---

## DRM (Widevine) — Netflix, Crunchyroll (premium)

The wrapper script auto-detects Widevine CDM from these locations (in order):

- `/usr/local/lib/browser_plugins/gmp-widevinecdm/` ← recommended
- `~/.config/zen/*/gmp-widevinecdm/`
- `~/.mozilla/firefox/*/gmp-widevinecdm/`
- `~/.config/BraveSoftware/Brave-Browser/WidevineCdm/`

If you have Brave Browser installed, Widevine is detected automatically. Otherwise, copy the `gmp-widevinecdm` folder from an existing Firefox or Chrome installation into your Zen profile.

> **Note:** DRM requires `MOZ_DISABLE_GMP_SANDBOX=1` because FreeBSD's Linux compat layer does not support Linux user namespaces. This is set automatically by the wrapper.

---

## Profile Configuration (user.js)

After the first launch, add the following to `~/.config/zen/<profile>/user.js`:

```js
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
user_pref("network.http.http3.enabled", false);
user_pref("security.sandbox.GMP.level", 0);
user_pref("security.sandbox.content.level", 1);
user_pref("media.eme.enabled", true);
user_pref("media.gmp-widevinecdm.enabled", true);
user_pref("media.gmp-widevinecdm.visible", true);
user_pref("media.gmp-widevinecdm.autoupdate", false);
user_pref("alerts.useSystemBackend", true);
```

---

## Notifications

Web notifications are routed via DBus to your system notification daemon (dunst, mako, etc.) as long as `DBUS_SESSION_BUS_ADDRESS` is set in your session.

---

## Please Note

- Only the Rocky Linux 9 (`linux_base-rl9`) compat layer is supported. Do not mix with `linux_base-ubuntu`.
- Hardware video acceleration is not available (Mesa llvmpipe is used instead). This is a FreeBSD compat layer limitation.
- The security sandbox warning inside Zen is expected and can be hidden via `userChrome.css` (see pkg-message after install).

---

## Launching

After installation, Zen Browser is available as:

```sh
/usr/local/bin/zen-browser
```

And as a `.desktop` entry at `/usr/local/share/applications/zen-browser.desktop`, compatible with `j4-dmenu-desktop`, `rofi`, and similar launchers.

---

## License

Port files (Makefile, scripts, stubs) are licensed under the [BSD 2-Clause License](LICENSE).  
Zen Browser itself is licensed under the [Mozilla Public License 2.0](https://www.mozilla.org/en-US/MPL/2.0/).
