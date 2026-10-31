# NUR Packages

An [NUR](https://github.com/nix-community/NUR) repository for packages we need.

![Build and populate cache](https://github.com/Forkprince/nur-packages/workflows/Build%20and%20populate%20cache/badge.svg)
[![Cachix Cache](https://img.shields.io/badge/cachix-forkprince-blue.svg)](https://forkprince.cachix.org)

## Package Types

This repository contains three types of packages:

| Type       | Description                                                                         |
|------------|-------------------------------------------------------------------------------------|
| `custom`   | Packages we maintain outside nixpkgs (e.g., `moonplayer`, `yaagl`).                 |
| `modified` | Packages adjusted to our needs (e.g., `beeper-nightly`, `osu-tachyon`).             |
| `support`  | Packages patched for extra platforms/architectures (e.g., `gimp`, `heroic`).        |

## Packages

<!-- PACKAGES:START -->
| Package | Description |
|---|---|
| [`ab-download-manager`](pkgs/abdm/default.nix) | [ab-download-manager](https://abdownloadmanager.com/), a Download Manager that speeds up your downloads |
| [`achico`](pkgs/achico/default.nix) | [achico](https://github.com/nuance-dev/achico/), minimal free macOS local file compressor app |
| [`altersend`](pkgs/altersend/default.nix) | [altersend](https://altersend.com), send files directly between devices over the internet - no cloud storage, no size limits |
| [`app-librescore`](pkgs/app-librescore/default.nix) | [app-librescore](https://github.com/LibreScore/app-librescore), app to download sheet music |
| [`armsx2`](pkgs/armsx2/default.nix) | [armsx2](https://armsx2.net), playstation 2 Emulator for ARM64 Platforms |
| [`astris`](pkgs/astris/default.nix) | [astris](https://codeberg.org/V380-Ori/Astris.Binaries), nintendo Switch emulator for Apple silicon Macs |
| [`beeper-nightly`](pkgs/beeper-nightly/default.nix) | [beeper-nightly](https://beeper.com), universal chat app |
| [`beswitched`](pkgs/beswitched/default.nix) | [beswitched](https://gitlab.com/dubiusfafa/beswitched-releases), native macOS Switch emulation app with cross-core saves and cloud backup |
| [`betteraudio`](pkgs/betteraudio/default.nix) | [betteraudio](https://betteraudio.pro/), one menu bar app. Every audio control macOS forgot to ship. |
| [`blip`](pkgs/blip/default.nix) | [blip](https://blip.net/), send any size file between devices |
| [`bluebubbles-server`](pkgs/bluebubbles-server/default.nix) | [bluebubbles-server](https://github.com/BlueBubblesApp/bluebubbles-server), server for forwarding iMessages to clients within the BlueBubbles App ecosystem |
| [`boxtron-bin`](pkgs/boxtron-bin/default.nix) | [boxtron-bin](https://github.com/dreamer/boxtron), steam Play compatibility tool to run DOS games using native Linux DOSBox (This is intended for use in the `programs.steam.extraCompatPackages` option only.) |
| [`cadcraft`](pkgs/cadcraft/default.nix) | [cadcraft](https://getartcraft.com/apps/cadcraft), computer-aided design and drafting application |
| [`clop`](pkgs/clop/default.nix) | [clop](https://lowtechguys.com/clop/), image, video and clipboard optimiser |
| [`compositor`](pkgs/compositor/default.nix) | [compositor](https://github.com/robbietilton/Compositor), the Photoshop alternative for Mac |
| [`compositor-meta`](pkgs/compositor-meta/default.nix) | compositor-meta |
| [`convierto`](pkgs/convierto/default.nix) | [convierto](https://github.com/nuance-dev/convierto/), native macOS file converter app |
| [`cot-editor`](pkgs/cot-editor/default.nix) | [cot-editor](https://coteditor.com/), plain-text editor for web pages, program source codes and more |
| [`creality-print`](pkgs/creality-print/default.nix) | [creality-print](https://github.com/CrealityOfficial/CrealityPrint), slicer and cloud services for some Creality FDM 3D printers |
| [`crossover`](pkgs/crossover/default.nix) | [crossover](https://www.codeweavers.com/products/crossover-mac), tool to run Windows software |
| [`deckcraft`](pkgs/deckcraft/default.nix) | [deckcraft](https://getartcraft.com/apps/deckcraft), presentation and slide deck editor |
| [`designcraft`](pkgs/designcraft/default.nix) | [designcraft](https://getartcraft.com/apps/designcraft), page layout and publishing application |
| [`diffusionbee`](pkgs/diffusionbee/default.nix) | [diffusionbee](https://diffusionbee.com/), run Stable Diffusion locally |
| [`dockdoor`](pkgs/dockdoor/default.nix) | [dockdoor](https://dockdoor.net/), window peeking utility app |
| [`dropshare`](pkgs/dropshare/default.nix) | [dropshare](https://dropshare.app/), file sharing solution |
| [`effectcraft`](pkgs/effectcraft/default.nix) | [effectcraft](https://getartcraft.com/apps/effectcraft), motion graphics and visual effects compositor |
| [`elixiroffice`](pkgs/elixiroffice/default.nix) | [elixiroffice](https://github.com/leag1234/ElixirOffice), open source office suite for users used to MS Office |
| [`emerald-launcher`](pkgs/emerald-launcher/default.nix) | [emerald-launcher](https://github.com/LCE-Hub/LCE-Emerald-Launcher), a FOSS, cross-platform launcher for Minecraft Legacy Edition |
| [`equibop`](pkgs/equibop/default.nix) | [equibop](https://github.com/Equicord/Equibop), custom Discord App aiming to give you better performance and improve linux support |
| [`equicord`](pkgs/equicord/default.nix) | equicord |
| [`figcraft`](pkgs/figcraft/default.nix) | [figcraft](https://getartcraft.com/apps/figcraft), interface design and prototyping |
| [`figura`](pkgs/figura/default.nix) | [figura](https://github.com/nuance-dev/figura/), free macOS native app to remove image backgrounds locally |
| [`filmcraft`](pkgs/filmcraft/default.nix) | [filmcraft](https://getartcraft.com/apps/filmcraft), video editor for nonlinear video editing |
| [`finetune`](pkgs/finetune/default.nix) | [finetune](https://github.com/ronitsingh10/FineTune), per-application volume mixer, equalizer, and audio router |
| [`flux-markdown`](pkgs/flux-markdown/default.nix) | [flux-markdown](https://github.com/xykong/flux-markdown), markdown Preview Enhanced for macOS QuickLook |
| [`fluxer-canary-bin`](pkgs/fluxer-canary-bin/default.nix) | [fluxer-canary-bin](https://fluxer.app), fluxer desktop client (canary) |
| [`fluxer-stable-bin`](pkgs/fluxer-stable-bin/default.nix) | [fluxer-stable-bin](https://fluxer.app), fluxer desktop client |
| [`folder-preview-pro`](pkgs/folder-preview-pro/default.nix) | [folder-preview-pro](https://anybox.ltd/folder-preview-pro), quick Look extension for folders |
| [`fx`](pkgs/fx/default.nix) | [fx](https://fx.sh), unix-like coding agent |
| [`genoffice`](pkgs/genoffice/default.nix) | [genoffice](https://genoffice.ai/), free, open-source AI Office suite: Docs, Sheets, Slides, PDF, Markdown and HTML editors with a built-in AI agent |
| [`ghostty`](pkgs/ghostty/default.nix) | ghostty |
| [`gimp`](pkgs/gimp/default.nix) | [gimp](https://www.gimp.org/), gNU Image Manipulation Program |
| [`github-desktop`](pkgs/github-desktop/default.nix) | [github-desktop](https://desktop.github.com/), gUI for managing Git and GitHub |
| [`gridcraft`](pkgs/gridcraft/default.nix) | [gridcraft](https://getartcraft.com/apps/gridcraft), spreadsheet editor |
| [`helium-nightly`](pkgs/helium-nightly/default.nix) | [helium](https://github.com/imputnet/helium), private, fast, and honest web browser (nightly builds) |
| [`helixnotes`](pkgs/helixnotes/default.nix) | [helixnotes](https://helixnotes.com), a local, open-source Markdown note-taking app. |
| [`heroic`](pkgs/heroic/default.nix) | [heroic](https://github.com/Heroic-Games-Launcher/HeroicGamesLauncher), native GOG, Epic, and Amazon Games Launcher for Linux, Windows and Mac |
| [`highball`](pkgs/highball/default.nix) | [highball](https://gauthierpiarrette.github.io/highball/), run Windows games on Apple Silicon |
| [`hyperkey`](pkgs/hyperkey/default.nix) | [hyperkey](https://hyperkey.app/), convert your caps lock key or any of your modifier keys to the hyper key |
| [`hyprcursor-bibata`](pkgs/hyprcursor-bibata/default.nix) | [hyprcursor-bibata](https://github.com/LOSEARDES77/Bibata-Cursor-hyprcursor), material Based Cursor Theme for Hyprland |
| [`hyprpanel`](pkgs/hyprpanel/default.nix) | [hyprpanel](https://github.com/pdf/hyprpanel), an opinionated panel/shell for the Hyprland compositor. |
| [`hytale`](pkgs/hytale/default.nix) | [hytale-launcher](https://hytale.com), official launcher for Hytale |
| [`keka-external-helper`](pkgs/keka-external-helper/default.nix) | [keka-external-helper](https://github.com/aonez/Keka/wiki/Default-application), helper application for the Keka file archiver |
| [`kryoto-desktop`](pkgs/kryoto-desktop/default.nix) | [kryoto-desktop](https://github.com/kyrotooooo/kryoto-desktop), find a game, download it and play it |
| [`kryoto-minecraft-launcher`](pkgs/kryoto-minecraft-launcher/default.nix) | [kryoto-minecraft-launcher](https://github.com/Kryoto-Dev/kryoto-minecraft-launcher), minecraft: Java Edition launcher with Fabric, Quilt, Forge, NeoForge and Modrinth/CurseForge mods |
| [`lightcraft`](pkgs/lightcraft/default.nix) | [lightcraft](https://getartcraft.com/apps/lightcraft), photo editor with color grading and RAW developing |
| [`linearmouse`](pkgs/linearmouse/default.nix) | [linearmouse](https://linearmouse.org/), customise mouse behavior |
| [`luxtorpeda-bin`](pkgs/luxtorpeda-bin/default.nix) | [luxtorpeda-bin](https://github.com/luxtorpeda-dev/luxtorpeda), steam Play compatibility tool to run games using native Linux engines (This is intended for use in the `programs.steam.extraCompatPackages` option only.) |
| [`macpacker`](pkgs/macpacker/default.nix) | [macpacker](https://github.com/sarensw/MacPacker), archive creator and extractor for macOS |
| [`macsai`](pkgs/macsai/default.nix) | [MacSai](https://github.com/iliyami/MacSai), open-source Mac cleaner, optimizer, and malware scanner |
| [`macusb`](pkgs/macusb/default.nix) | [macusb](https://macusb.app/), the all-in-one bootable USB creator for Mac |
| [`mcman`](pkgs/mcman/default.nix) | [mcman](https://github.com/deniz-blue/mcman), powerful Minecraft Server Manager CLI |
| [`mcpelauncher-swift`](pkgs/mcpelauncher-swift/default.nix) | [mcpelauncher-swift](https://github.com/hugonote/mcpelauncher-swift), native SwiftUI launcher for Minecraft Bedrock on macOS |
| [`micro`](pkgs/micro/default.nix) | micro |
| [`moonplayer`](pkgs/moonplayer/default.nix) | [moonplayer](https://github.com/coslyk/moonplayer), video player that can play online videos from YouTube, Bilibili etc |
| [`muxy`](pkgs/muxy/default.nix) | [muxy](https://muxy.app/), lightweight and Memory efficient terminal for Mac built with SwiftUI and libghostty |
| [`nexa`](pkgs/nexa/default.nix) | [nexa](https://nexa.fish), end-to-end encrypted chat, calls and servers |
| [`nintoolbox`](pkgs/nintoolbox/default.nix) | [nintoolbox](https://github.com/quatric/nintoolbox), toolbox for Nintendo game file formats |
| [`nintoolbox-gui`](pkgs/nintoolbox-gui/default.nix) | [nintoolbox-gui](https://github.com/quatric/nintoolbox), graphical interface for the Nintoolbox command line tools |
| [`noisetorch`](pkgs/noisetorch/default.nix) | [NoiseTorch](https://github.com/ForkPrince/NoiseTorch), virtual microphone device with noise supression for PulseAudio (ForkPrince fork) |
| [`note-block-studio`](pkgs/note-block-studio/default.nix) | [note-block-studio](https://github.com/OpenNBS/NoteBlockStudio), an open-source Minecraft music maker. |
| [`nuvio`](pkgs/nuvio/default.nix) | [nuvio](https://nuvio.tv/), watch your library, anywhere |
| [`oak-editor`](pkgs/oak-editor/default.nix) | [oak-editor](https://github.com/OakVideoEditorCommunity/oak), a free non-linear video editor for Linux, macOS, and Windows |
| [`obs-studio`](pkgs/obs-studio/default.nix) | [obs-studio](https://obsproject.com), free and open source software for video recording and live streaming |
| [`opendisk`](pkgs/opendisk/default.nix) | [opendisk](https://github.com/137137137/OpenDisk), fast macOS disk-usage analyzer. |
| [`openemu`](pkgs/openemu/default.nix) | [openemu](https://openemu.org/), retro video game emulation |
| [`openemu-meta`](pkgs/openemu-meta/default.nix) | openemu-meta |
| [`openemu-silicon`](pkgs/openemu-silicon/default.nix) | [openemu-silicon](https://github.com/OpenEmu-Silicon/OpenEmu-Silicon), native ARM64 port of OpenEmu for Apple silicon MacBooks |
| [`openmtp`](pkgs/openmtp/default.nix) | [openmtp](https://openmtp.ganeshrvel.com/), advanced Android File Transfer Application |
| [`openrct2`](pkgs/openrct2/default.nix) | [openrct2](https://openrct2.io/), open source re-implementation of RollerCoaster Tycoon 2 (original game required) |
| [`opentubex`](pkgs/opentubex/default.nix) | [opentubex](https://opentubex.org), highly customizable, open-source YouTube client with privacy in mind |
| [`orb`](pkgs/orb/default.nix) | [orb](https://orb-tools.com), modern and powerful HTTP client for the command line, with HTTP/1.1, HTTP/2, HTTP/3 and WebSocket support |
| [`orbolay`](pkgs/orbolay/default.nix) | [orbolay](https://github.com/SpikeHD/Orbolay), quick, small, native, multi-platform Discord overlay alternative |
| [`orca`](pkgs/orca/default.nix) | [orca](https://onorca.dev/), the ADE for working with a fleet of parallel agents. |
| [`orca-slicer`](pkgs/orca-slicer/default.nix) | [orca-slicer](https://github.com/SoftFever/OrcaSlicer), g-code generator for 3D printers (Bambu, Prusa, Voron, VzBot, RatRig, Creality, etc.) |
| [`osu-tachyon`](pkgs/osu-tachyon/default.nix) | [osu-tachyon](https://osu.ppy.sh), rhythm is just a *click* away (AppImage version for score submission and multiplayer, and binary distribution for Darwin systems) |
| [`overlayed`](pkgs/overlayed/default.nix) | [overlayed](https://github.com/overlayeddev/overlayed), modern discord voice chat overlay |
| [`parabolic`](pkgs/parabolic/default.nix) | [parabolic](https://github.com/NickvisionApps/Parabolic), graphical frontend for yt-dlp to download video and audio |
| [`passepartout`](pkgs/passepartout/default.nix) | [passepartout](https://passepartoutvpn.app/), openVPN and WireGuard client |
| [`pcsx2`](pkgs/pcsx2/default.nix) | [pcsx2](https://pcsx2.net/), playstation 2 emulator (precompiled binary, repacked from official website) |
| [`pdfcraft`](pkgs/pdfcraft/default.nix) | [pdfcraft](https://getartcraft.com/apps/pdfcraft), pDF editor for viewing, annotating and manipulating PDF documents |
| [`pearcleaner`](pkgs/pearcleaner/default.nix) | [pearcleaner](https://itsalin.com/appInfo/?id=pearcleaner), a free, source-available and fair-code licensed mac app cleaner |
| [`peazip`](pkgs/peazip/default.nix) | [peazip](https://peazip.github.io), file and archive manager |
| [`photocraft`](pkgs/photocraft/default.nix) | [photocraft](https://getartcraft.com/apps/photocraft), photo editor for raster image editing |
| [`pixelflasher`](pkgs/pixelflasher/default.nix) | [pixelflasher](https://github.com/badabing2005/PixelFlasher), pixel™ phone flashing GUI utility with features |
| [`playcover`](pkgs/playcover/default.nix) | [playcover](https://playcover.io/), sideload iOS apps and games |
| [`proton-cachyos-arm-bin`](pkgs/proton-cachyos-bin/default.nix) | [proton-cachyos-gi-cn-bin](https://github.com/CachyOS/proton-cachyos), compatibility tool for Steam Play based on Wine and additional components (This is intended for use in the `programs.steam.extraCompatPackages` option only.) |
| [`proton-cachyos-v1-bin`](pkgs/proton-cachyos-bin/default.nix) | [proton-cachyos-gi-cn-bin](https://github.com/CachyOS/proton-cachyos), compatibility tool for Steam Play based on Wine and additional components (This is intended for use in the `programs.steam.extraCompatPackages` option only.) |
| [`proton-cachyos-v3-bin`](pkgs/proton-cachyos-bin/default.nix) | [proton-cachyos-gi-cn-bin](https://github.com/CachyOS/proton-cachyos), compatibility tool for Steam Play based on Wine and additional components (This is intended for use in the `programs.steam.extraCompatPackages` option only.) |
| [`proton-em-bin`](pkgs/proton-em-bin/default.nix) | [proton-em-bin](https://github.com/Etaash-mathamsetty/Proton), a Development Oriented Compatibility tool for Steam Play based on Wine and additional components (This is intended for use in the `programs.steam.extraCompatPackages` option only.) |
| [`proton-ge-rtsp-bin`](pkgs/proton-ge-rtsp-bin/default.nix) | [proton-ge-rtsp-bin](https://github.com/SpookySkeletons/proton-ge-rtsp), compatibility tool for Steam Play based on Wine and additional components (This is intended for use in the `programs.steam.extraCompatPackages` option only.) |
| [`proton-sarek-bin`](pkgs/proton-sarek-bin/default.nix) | [proton-sarek-bin](https://github.com/pythonlover02/Proton-Sarek), compatibility tool for Steam Play based on Wine and additional components, with a focus on older PCs (This is intended for use in the `programs.steam.extraCompatPackages` option only.) |
| [`punktfunk-client`](pkgs/punktfunk-client/default.nix) | [punktfunk-client](https://docs.punktfunk.unom.io), low-latency desktop and game streaming client |
| [`puremac`](pkgs/puremac/default.nix) | [puremac](https://www.moamenbasel.com/PureMac/), free, open-source macOS cleaner. CleanMyMac alternative with zero telemetry. |
| [`quiver-launcher`](pkgs/quiver-launcher/default.nix) | [quiver-launcher](https://github.com/tgeorgiadis/quiver-launcher), cross-platform game launcher and library manager |
| [`re-lunatic-player`](pkgs/re-lunatic-player/default.nix) | [re-lunatic-player](https://github.com/Prince527Github/Re-Lunatic-Player), music player for Gensokyo Radio |
| [`redream-dev`](pkgs/redream-dev/default.nix) | [redream-dev](https://redream.io), dreamcast emulator |
| [`removemacai`](pkgs/removemacai/default.nix) | [removemacai](https://github.com/omlahore/RemoveMacAI), turn off Apple Intelligence on macOS 27 and remove its models |
| [`retroarch`](pkgs/retroarch/default.nix) | [retroarch](https://libretro.com), multi-platform emulator frontend for libretro cores |
| [`rhythia`](pkgs/rhythia/default.nix) | [rhythia](https://github.com/Rhythia/Client), aim-based rhythm game client, built in Godot 4 |
| [`roblox`](pkgs/roblox/default.nix) | [roblox](https://www.roblox.com), online multiplayer game platform |
| [`rpcs3`](pkgs/rpcs3/default.nix) | [rpcs3](https://rpcs3.net/), pS3 emulator/debugger |
| [`rustdesk`](pkgs/rustdesk/default.nix) | [rustdesk](https://rustdesk.com), virtual / remote desktop infrastructure for everyone! Open source TeamViewer / Citrix alternative |
| [`screendrop`](pkgs/screendrop/default.nix) | [screendrop](https://github.com/fayazara/screendrop), a beautiful screenshot, screen recording and loom alternative |
| [`sfw`](pkgs/sfw/default.nix) | [sfw](https://github.com/SocketDev/sfw-free), wraps your package manager, preventing installation of malicious packages. |
| [`sm64plus`](pkgs/sm64plus/default.nix) | [sm64plus](https://github.com/MorsGames/sm64plus), a standalone fork of the Super Mario 64 PC port with quality of life improvements |
| [`sonixd`](pkgs/sonixd/default.nix) | [sonixd](https://github.com/jeffvli/sonixd), full-featured Subsonic/Jellyfin compatible desktop music player |
| [`soundcraft`](pkgs/soundcraft/default.nix) | [soundcraft](https://getartcraft.com/apps/soundcraft), digital audio workstation for audio recording, editing and mixing |
| [`steam`](pkgs/steam/default.nix) | [steam](https://store.steampowered.com/), digital distribution platform |
| [`streamnook`](pkgs/streamnook/default.nix) | [streamnook](https://streamnook.app), a native desktop client for Twitch, Kick and YouTube multi-streaming |
| [`sublime-text`](pkgs/sublime-text/default.nix) | [sublime-text](https://www.sublimetext.com/), sophisticated text editor for code, markup and prose |
| [`supercharge`](pkgs/supercharge/default.nix) | [supercharge](https://sindresorhus.com/supercharge), elevate your Mac experience |
| [`sysbar`](pkgs/sysbar/default.nix) | [sysbar](https://github.com/System64fumo/sysbar), modular status bar for Wayland written in gtkmm4 |
| [`syslock`](pkgs/syslock/default.nix) | [syslock](https://github.com/System64fumo/syslock), simple screen locker for Wayland written in gtkmm4 |
| [`tenacity`](pkgs/tenacity/default.nix) | [tenacity](https://tenacityaudio.org/), sound editor with graphical UI |
| [`tiny-rdm`](pkgs/tiny-rdm/default.nix) | [tiny-rdm](https://github.com/tiny-craft/tiny-rdm), modern, colorful, super lightweight Redis GUI client |
| [`tinywiibackupmanager`](pkgs/tinywiibackupmanager/default.nix) | [tinywiibackupmanager](https://github.com/mq1/TinyWiiBackupManager), a tiny game backup and homebrew app manager for the Wii |
| [`twintaillauncher`](pkgs/twintaillauncher/default.nix) | [twintaillauncher](https://github.com/TwintailTeam/TwintailLauncher), a multi-platform launcher for your anime games |
| [`vectorcraft`](pkgs/vectorcraft/default.nix) | [vectorcraft](https://getartcraft.com/apps/vectorcraft), vector graphics editor |
| [`vmware-fusion`](pkgs/vmware-fusion/default.nix) | [vmware-fusion](https://www.vmware.com/products/desktop-hypervisor/workstation-and-fusion), create, manage, and run virtual machines |
| [`vorssaint`](pkgs/vorssaint/default.nix) | [vorssaint](https://vorssaint.com), free and open-source macOS menu bar toolkit. |
| [`vscode`](pkgs/vscode/default.nix) | vscode |
| [`waterfox-bin`](pkgs/waterfox-bin/default.nix) | [waterfox](https://www.waterfox.net/), fast and Private Web Browser |
| [`wg-nord`](pkgs/wg-nord/default.nix) | [wg-nord](https://github.com/n-thumann/wg-nord), wireGuard configuration generator for NordVPN |
| [`whisky`](pkgs/whisky/default.nix) | [whisky](https://frankea.github.io/Whisky), wine wrapper built with SwiftUI (frankea fork) |
| [`wiiudownloader`](pkgs/wiiudownloader/default.nix) | [wiiudownloader](https://github.com/Xpl0itU/WiiUDownloader), cross-platform Wii U NUS downloader for Windows, macOS & Linux |
| [`wordcraft`](pkgs/wordcraft/default.nix) | [wordcraft](https://getartcraft.com/apps/wordcraft), word processor for document creation and editing |
| [`xuan`](pkgs/xuan/default.nix) | [xuan](https://github.com/silverling/xuan), an image editor for Linux, inspired by Compositor and ported from it. |
| [`yaagl`](pkgs/yaagl/default.nix) | [yaagl-gi-cn](https://github.com/yaagl/yet-another-anime-game-launcher), yet another anime game launcher for GI (cn) |
| [`yaagl-hsr`](pkgs/yaagl/default.nix) | [yaagl-hsr-cn](https://github.com/yaagl/yet-another-anime-game-launcher), yet another anime game launcher for HSR (cn) |
| [`yaagl-hsr-os`](pkgs/yaagl/default.nix) | [yaagl-hsr-os](https://github.com/yaagl/yet-another-anime-game-launcher), yet another anime game launcher for HSR (os) |
| [`yaagl-os`](pkgs/yaagl/default.nix) | [yaagl-gi-os](https://github.com/yaagl/yet-another-anime-game-launcher), yet another anime game launcher for GI (os) |
| [`yaagl-zzz`](pkgs/yaagl/default.nix) | [yaagl-zzz-cn](https://github.com/yaagl/yet-another-anime-game-launcher), yet another anime game launcher for ZZZ (cn) |
| [`yaagl-zzz-os`](pkgs/yaagl/default.nix) | [yaagl-zzz-os](https://github.com/yaagl/yet-another-anime-game-launcher), yet another anime game launcher for ZZZ (os) |
| [`yapfast`](pkgs/yapfast/default.nix) | [yapfast](https://github.com/yapfast/yapfast), native Discord client that stays light on memory |
| [`zed-editor`](pkgs/zed-editor/default.nix) | zed-editor |
| [`zeiger`](pkgs/zeiger/default.nix) | [zeiger](https://zeigerviewer.com/), fast, free, no-nonsense image viewer |
<!-- PACKAGES:END -->
