{
  lib,
  stdenv,
  stdenvNoCC,
  fetchurl,
  dpkg,
  buildFHSEnv,
  OVMF,
}:

let
  pname = "claude-desktop";
  version = "2.9939.4";

  source =
    if stdenv.hostPlatform.isAarch64 then
      {
        arch = "arm64";
        hash = "sha256-EI7XnqFksIxPoLtDh97vR3mVez8Pmy2YmONZ82Pr8bw=";
      }
    else
      {
        arch = "amd64";
        hash = "sha256-PP3bI78pEeBeJ7TtOFa455XflGQ7LDW1nesxfPmVvKA=";
      };

  src = fetchurl {
    url = "https://downloads.claude.ai/claude-desktop/apt/stable/pool/main/c/claude-desktop/claude-desktop_${version}_${source.arch}.deb";
    inherit (source) hash;
  };

  meta = {
    description = "Official Claude Desktop application (Linux beta)";
    homepage = "https://claude.ai/download";
    license = lib.licenses.unfree;
    mainProgram = pname;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = [
      {
        name = "Souheab";
        github = "Souheab";
        githubId = 85948717;
      }
    ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };

  unwrapped = stdenvNoCC.mkDerivation {
    pname = "${pname}-unwrapped";
    inherit version src meta;

    nativeBuildInputs = [ dpkg ];
    dontUnpack = true;
    dontBuild = true;
    dontFixup = true;

    installPhase = ''
      runHook preInstall

      # Extract without running Debian maintainer scripts or preserving setuid.
      dpkg --fsys-tarfile "$src" | tar --extract --no-same-permissions
      mkdir -p "$out/lib" "$out/share"
      cp -r usr/lib/claude-desktop "$out/lib/"
      cp -r usr/share/{applications,icons,doc} "$out/share/"

      runHook postInstall
    '';
  };

  firmwarePrefix = if stdenv.hostPlatform.isAarch64 then "AAVMF" else "OVMF";
in
buildFHSEnv {
  inherit pname version meta;

  # Preserve upstream Electron, native modules, and downloaded helper binaries.
  # Cowork also probes fixed Debian firmware paths in its compiled JavaScript.
  targetPkgs =
    pkgs: with pkgs; [
      alsa-lib
      at-spi2-core
      cairo
      cups
      dbus
      expat
      glib
      gtk3
      libGL
      libayatana-appindicator
      libcap_ng
      libdrm
      libgbm
      libnotify
      libpulseaudio
      libsecret
      libseccomp
      libuuid
      libxkbcommon
      nspr
      nss
      pango
      qemu
      stdenv.cc.cc.lib
      systemd
      xdg-utils
      libx11
      libxcomposite
      libxdamage
      libxext
      libxfixes
      libxrandr
      libxtst
      libxcb
    ];
  multiPkgs = _: [ ];

  runScript = "${unwrapped}/lib/claude-desktop/claude-desktop";

  extraBuildCommands = ''
    mkdir -p "$out/usr/share/${firmwarePrefix}"
    ln -s ${OVMF.fd}/FV/${firmwarePrefix}_CODE.fd \
      "$out/usr/share/${firmwarePrefix}/${firmwarePrefix}_CODE.fd"
    ln -s ${OVMF.fd}/FV/${firmwarePrefix}_VARS.fd \
      "$out/usr/share/${firmwarePrefix}/${firmwarePrefix}_VARS.fd"
  '';

  extraInstallCommands = ''
    mkdir -p "$out/share"
    cp -r ${unwrapped}/share/{applications,icons,doc} "$out/share/"
    chmod u+w "$out/share/applications/com.anthropic.Claude.desktop"
    substituteInPlace "$out/share/applications/com.anthropic.Claude.desktop" \
      --replace-fail "Exec=claude-desktop" "Exec=$out/bin/claude-desktop"
  '';

  passthru = { inherit src unwrapped; };
}
