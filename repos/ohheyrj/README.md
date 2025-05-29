# nur-packages

**My personal [NUR](https://github.com/nix-community/NUR) repository**

<!-- Remove this if you don't use github actions -->
![Build and populate cache](https://github.com/ohheyrj/nur/workflows/Build%20and%20populate%20cache/badge.svg)

[![Cachix Cache](https://img.shields.io/badge/cachix-ohheyrj-blue.svg)](https://ohheyrj.cachix.org)

This repository contains a curated collection of custom Nix packages for macOS (Darwin), built to fill gaps in the official [nixpkgs](https://github.com/NixOS/nixpkgs) repository.

These packages were created because they are **not currently available in `nixpkgs`**, or are pending review in upstream pull requests. The long-term goal is to contribute each package **back to upstream** once they meet the necessary quality and packaging standards.

Packages are grouped by category, and each entry includes metadata such as:

These packages are available via nur.

- ✅ Version
- 🔗 Homepage & changelog
- 🖥️ Supported platforms
- 🛡️ License
- 📦 PR & tracker links (if submitted upstream)

<!--table:start-->
## 📦 Packages by Category

### 🗂️ Table of Contents
- [💬 Chat](#chat)
- [🎮 Gaming](#gaming)
- [🎵 Media](#media)
- [📦 Other](#other)
- [🧰 Utilities](#utilities)

<details id="chat">
<summary><h2>💬 Chat (2 packages)</h2></summary>

### 🧰 chatterino `v2.5.3`
- 💡 **Description:** Chat client for Twitch
- 🛡️ **License:** mit
- 🖥️ **Platforms:** darwin
- 🔄 **Auto-updated:** Uses nvfetcher for version management
- 🌐 **Homepage:** [chatterino Website](https://chatterino.com)
- 📄 **Changelog:** [CHANGELOG](https://github.com/Chatterino/chatterino2/blob/master/CHANGELOG.md)

### 🧰 unknown `vunknown`
- 💡 **Description:** Signal Desktop links with Signal on Android or iOS and lets you message from your Windows, macOS, and Linux computers.
- 🛡️ **License:** agpl3Only
- 🖥️ **Platforms:** darwin
- 🔄 **Auto-updated:** Uses nvfetcher for version management
- 🌐 **Homepage:** [unknown Website](https://signal.org)
- 📄 **Changelog:** [CHANGELOG](https://github.com/signalapp/Signal-Desktop/releases)

</details>

<details id="gaming">
<summary><h2>🎮 Gaming (1 packages)</h2></summary>

### 🧰 unknown `vunknown`
- 💡 **Description:** PS Remote Play is a free app that lets you stream and play your PS5 or PS4 games on compatible devices like smartphones, tablets, PCs, and Macs, allowing you to game remotely over Wi-Fi or mobile data.
- 🛡️ **License:** unfree
- 🖥️ **Platforms:** darwin
- 🔄 **Auto-updated:** Uses nvfetcher for version management
- 🌐 **Homepage:** [unknown Website](https://remoteplay.dl.playstation.net/remoteplay/lang/gb/)

</details>

<details id="media">
<summary><h2>🎵 Media (3 packages)</h2></summary>

### 🧰 kobo-desktop `v0-unstable-2025-05-11`
- 💡 **Description:** Kobo Desktop is a free app for Windows and Mac that lets you buy, read, and manage eBooks, as well as sync them with your Kobo eReader.
- 🛡️ **License:** unfree
- 🖥️ **Platforms:** darwin
- 🌐 **Homepage:** [kobo-desktop Website](https://www.kobo.com/gb/en/p/desktop)

### 🧰 openaudible `v4.5.3`
- 💡 **Description:** OpenAudible is a cross-platform desktop app that lets Audible users download, convert, and manage their audiobooks in MP3 or M4B formats for offline listening.
- 🛡️ **License:** asl20
- 🖥️ **Platforms:** darwin
- 🔄 **Auto-updated:** Uses nvfetcher for version management
- 🌐 **Homepage:** [openaudible Website](https://openaudible.org/)
- 📄 **Changelog:** [CHANGELOG](https://openaudible.org/versions)

### 🧰 handbrake `v1.9.2`
- 💡 **Description:** HandBrake is an open-source video transcoder available for Linux, Mac, and Windows.
- 🛡️ **License:** gpl2Only
- 🖥️ **Platforms:** darwin
- 🔄 **Auto-updated:** Uses nvfetcher for version management
- 🌐 **Homepage:** [handbrake Website](https://handbrake.fr)
- 📄 **Changelog:** [CHANGELOG](https://github.com/HandBrake/HandBrake/releases)

</details>

<details id="other">
<summary><h2>📦 Other (1 packages)</h2></summary>

### 🧰 unknown `vunknown`
- 💡 **Description:** Garmin BaseCamp is a free desktop app for planning outdoor adventures and managing GPS data with Garmin devices.
- 🛡️ **License:** unfree
- 🖥️ **Platforms:** darwin
- 🔄 **Auto-updated:** Uses nvfetcher for version management
- 🌐 **Homepage:** [unknown Website](https://www.garmin.com/en-GB/software/basecamp/)
- 📄 **Changelog:** [CHANGELOG](https://www8.garmin.com/support/download_details.jsp?id=4449)

</details>

<details id="utilities">
<summary><h2>🧰 Utilities (7 packages)</h2></summary>

### 🧰 alfred5 `v5.6.2`
- 💡 **Description:** Productivity app for macOS that boosts efficiency with hotkeys, keywords, text expansion, and powerful workflows.
- 🛡️ **License:** unfree
- 🖥️ **Platforms:** darwin
- 🌐 **Homepage:** [alfred5 Website](https://www.alfredapp.com)

### 🧰 bartender5 `v5-3-6`
- 💡 **Description:** Bartender is a macOS app that lets you manage and hide menu bar items, improving workflow with search, hotkeys, and automation.
- 🛡️ **License:** unfree
- 🖥️ **Platforms:** darwin
- 🔄 **Auto-updated:** Uses nvfetcher for version management
- 🌐 **Homepage:** [bartender5 Website](https://www.macbartender.com)
- 📄 **Changelog:** [CHANGELOG](https://www.macbartender.com/Bartender5/release_notes/)

### 🧰 komiser `vunknown`
- 💡 **Description:** Cloud cost visibility and optimisation tool
- 🛡️ **License:** mit
- 🖥️ **Platforms:** aarch64-darwin, x86_64-darwin, x86_64-linux
- 🔄 **Auto-updated:** Uses nvfetcher for version management
- 🌐 **Homepage:** [komiser Website](https://github.com/tailwarden/komiser)

### 🧰 balenaEtcher `v2.1.2`
- 💡 **Description:** Flash OS images to SD cards & USB drives, safely and easily.
- 🛡️ **License:** asl20
- 🖥️ **Platforms:** aarch64-darwin
- 🔄 **Auto-updated:** Uses nvfetcher for version management
- 🌐 **Homepage:** [balenaEtcher Website](https://github.com/balena-io/etcher)
- 📄 **Changelog:** [CHANGELOG](https://github.com/balena-io/etcher/blob/master/CHANGELOG.md)

### 🧰 cryptomator `v1.16.2`
- 💡 **Description:** Cryptomator offers multi-platform transparent client-side encryption of your files in the cloud.
- 🛡️ **License:** gpl3Only
- 🖥️ **Platforms:** aarch64-darwin
- 🔄 **Auto-updated:** Uses nvfetcher for version management
- 🌐 **Homepage:** [cryptomator Website](https://github.com/cryptomator/cryptomator)
- 📄 **Changelog:** [CHANGELOG](https://github.com/cryptomator/cryptomator/releases)

### 🧰 hazel `v6.0.4`
- 💡 **Description:** Automated Organization for Your Mac.
- 🛡️ **License:** unfree
- 🖥️ **Platforms:** aarch64-darwin
- 🔄 **Auto-updated:** Uses nvfetcher for version management
- 🌐 **Homepage:** [hazel Website](https://www.noodlesoft.com)
- 📄 **Changelog:** [CHANGELOG](https://www.noodlesoft.com/release_notes)

### 🧰 gitkraken-cli `vunknown`
- 💡 **Description:** GitKraken CLI is the developer tool that transforms how you interact with Git.
- 🛡️ **License:** unfree
- 🖥️ **Platforms:** aarch64-darwin, x86_64-darwin
- 🔄 **Auto-updated:** Uses nvfetcher for version management
- 🌐 **Homepage:** [gitkraken-cli Website](https://www.gitkraken.com/cli)
- 📄 **Changelog:** [CHANGELOG](https://github.com/gitkraken/gk-cli/releases)

</details>

<!--table:end-->
