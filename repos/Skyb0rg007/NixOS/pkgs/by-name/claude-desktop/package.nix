# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: Copyright 2024 (c) Numtide
{
  fetchurl,
  lib,
  autoPatchelfHook,
  makeWrapper,
  stdenvNoCC,
  bintools,
  copyDesktopItems,
  makeDesktopItem,

  # Directly linked (DT_NEEDED); autoPatchelfHook resolves these from
  # buildInputs and fails the build if any are missing.
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  atk,
  cairo,
  cups,
  dbus,
  expat,
  gcc-unwrapped,
  glib,
  gtk3,
  libdrm,
  libX11,
  libxcb,
  libXcomposite,
  libXdamage,
  libXext,
  libXfixes,
  libXrandr,
  libxkbcommon,
  libgbm,
  nspr,
  nss,
  pango,

  # Provides libudev, which the main binary links directly. The libs-only
  # build avoids pulling the whole systemd closure.
  systemdLibs,

  # Loaded at runtime via dlopen. Nothing lists these in DT_NEEDED, so they go
  # in runtimeDependencies to land on the RUNPATH regardless.
  libglvnd,
  libsecret,
  libnotify,
  libpulseaudio,
  libayatana-appindicator,
  libXcursor,
  pipewire,
  wayland,
  xdg-utils,

  # Needed by the bundled virtiofsd, which backs Cowork's virtual machines.
  libcap_ng,
  libseccomp,

  buildFHSEnv,
  mesa,
  vulkan-loader,

  # Needed for XDG_ICON_DIRS and GSETTINGS_SCHEMAS_PATH.
  adwaita-icon-theme,
  gsettings-desktop-schemas,

  # Command line arguments which are always passed to the application.
  commandLineArgs ? "",
}:

let
  pname = "claude-desktop";

  # update.py refreshes version/urls/hashes from Anthropic's APT index.
  versionData = builtins.fromJSON (builtins.readFile ./hashes.json);
  inherit (versionData) version urls hashes;

  platform = stdenvNoCC.hostPlatform.system;

  # x-scheme-handler/claude registers the OAuth sign-in handler.
  desktopItem = makeDesktopItem {
    name = "claude-desktop";
    desktopName = "Claude";
    genericName = "AI Assistant";
    comment = "Desktop application for Claude.ai";
    exec = "claude-desktop %U";
    icon = "claude-desktop";
    keywords = [
      "AI"
      "Chat"
      "Assistant"
      "Claude"
      "Code"
      "LLM"
    ];
    categories = [
      "Utility"
      "Development"
    ];
    startupNotify = true;
    startupWMClass = "claude-desktop";
    singleMainWindow = true;
    mimeTypes = [ "x-scheme-handler/claude" ];
    actions = {
      NewChat = {
        name = "New chat";
        exec = "claude-desktop claude://claude.ai/new";
      };
      NewCode = {
        name = "New Claude Code session";
        exec = "claude-desktop claude://code/new";
      };
    };
  };

  passthru = {
    category = "AI Coding Agents";
  };

  meta = with lib; {
    description = "Desktop application for Claude.ai";
    homepage = "https://claude.ai";
    # No upstream versioned changelog or release tags exist.
    changelog = "https://claude.ai/download";
    license = lib.licenses.unfree;
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    maintainers = with maintainers; [ flexiondotorg ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    mainProgram = "claude-desktop";
  };

  unwrapped = stdenvNoCC.mkDerivation {
    inherit
      pname
      version
      meta
      passthru
      ;

    src = fetchurl {
      url = urls.${platform} or (throw "Unsupported system: ${platform}");
      hash = hashes.${platform} or (throw "Unsupported system: ${platform}");
    };

    nativeBuildInputs = [
      autoPatchelfHook
      copyDesktopItems
      makeWrapper
    ];

    buildInputs = [
      adwaita-icon-theme
      alsa-lib
      at-spi2-atk
      at-spi2-core
      atk
      cairo
      cups
      dbus
      expat
      gcc-unwrapped.lib
      glib
      gsettings-desktop-schemas
      gtk3
      libcap_ng
      libdrm
      libgbm
      libseccomp
      libX11
      libxcb
      libXcomposite
      libXcursor
      libXdamage
      libXext
      libXfixes
      libXrandr
      libxkbcommon
      nspr
      nss
      pango
      systemdLibs
    ];

    # dlopen()ed at runtime, so autoPatchelfHook cannot discover them from
    # DT_NEEDED; list them here to force them onto every payload's RUNPATH.
    runtimeDependencies = [
      libayatana-appindicator
      libglvnd
      libnotify
      libpulseaudio
      libsecret
      pipewire
      wayland
    ];

    desktopItems = [ desktopItem ];

    unpackPhase = ''
      runHook preUnpack
      ${lib.getExe' bintools "ar"} x $src
      tar xf data.tar.xz
      runHook postUnpack
    '';

    installPhase = ''
      runHook preInstall

      # Keep the upstream usr/lib layout so bundled libs (e.g. libffmpeg.so)
      # resolve next to the main binary.
      mkdir -p $out/lib $out/bin $out/share
      cp -a usr/lib/claude-desktop $out/lib/claude-desktop
      cp -a usr/share/icons $out/share/icons
      cp -a usr/share/doc $out/share/doc

      # autoPatchelfHook sets the interpreter and RUNPATHs. The wrapper only adds
      # the app dir (so the bundled GL/Vulkan libs find each other), xdg-utils on
      # PATH, and the icon/schema data dirs.
      makeWrapper "$out/lib/claude-desktop/claude-desktop" "$out/bin/claude-desktop" \
        --prefix LD_LIBRARY_PATH : "$out/lib/claude-desktop" \
        --suffix PATH : "${lib.makeBinPath [ xdg-utils ]}" \
        --prefix XDG_DATA_DIRS : "$XDG_ICON_DIRS:$GSETTINGS_SCHEMAS_PATH" \
        --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}" \
        --add-flags ${lib.escapeShellArg commandLineArgs}

      runHook postInstall
    '';
  };
in
# The app downloads and execs generic-linux binaries (claude-code CLI, uv) at
# runtime, which need an FHS loader path.
buildFHSEnv {
  inherit pname version meta;
  passthru = passthru // {
    inherit unwrapped;
  };

  targetPkgs = _: [
    unwrapped
    gcc-unwrapped.lib
    # GPU acceleration
    libglvnd
    mesa
    libgbm
    vulkan-loader
  ];

  runScript = "claude-desktop";

  extraInstallCommands = ''
    ln -s ${unwrapped}/share $out/share
  '';
}
