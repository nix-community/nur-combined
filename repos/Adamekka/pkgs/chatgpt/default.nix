{ buildFHSEnv
, cacert
, curl
, desktop-file-utils
, dpkg
, fetchurl
, lib
, maintainer
, python3
, stdenvNoCC
, writeShellApplication
, writeShellScript
}:

let
  source = builtins.fromJSON (builtins.readFile ./source.json);
  meta = {
    description = "Official ChatGPT desktop application with Codex";
    homepage = "https://developers.openai.com/codex/linux/linux-app/";
    license = lib.licenses.unfree;
    mainProgram = "chatgpt";
    maintainers = [ maintainer ];
    platforms = [ "aarch64-linux" "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
  unwrapped = stdenvNoCC.mkDerivation {
    # Share the public name so a chatgpt-only allowUnfreePredicate also permits the payload.
    pname = "chatgpt";
    inherit (source) version;
    inherit meta;

    src = fetchurl source.${stdenvNoCC.hostPlatform.system};
    nativeBuildInputs = [ dpkg ];
    dontBuild = true;
    dontConfigure = true;
    # The FHS launcher handles vendor binaries, including tools downloaded after installation.
    dontFixup = true;
    unpackPhase = ''
      runHook preUnpack
      dpkg-deb -x "$src" .
      runHook postUnpack
    '';
    installPhase = ''
      runHook preInstall
      mkdir -p "$out/lib" "$out/share"
      cp -a usr/lib/chatgpt "$out/lib/"
      cp -a usr/share/applications usr/share/doc usr/share/pixmaps "$out/share/"
      runHook postInstall
    '';
  };
in
buildFHSEnv {
  pname = "chatgpt";
  inherit (source) version;
  inherit meta;

  targetPkgs = pkgs: with pkgs; [
    alsa-lib
    at-spi2-core
    cairo
    cups
    curl
    dbus
    expat
    fontconfig
    freetype
    gdk-pixbuf
    git
    glib
    gtk3
    lcms2
    libGL
    libdrm
    libgbm
    libnotify
    libpulseaudio
    libusb1
    libx11
    libxcb
    libxcomposite
    libxcrypt-legacy
    libxdamage
    libxext
    libxfixes
    libxkbcommon
    libxrandr
    nspr
    nss
    pango
    pipewire
    qt5.qtbase
    qt6.qtbase
    systemdLibs
    util-linux
    vulkan-loader
    wayland
    xdg-utils
    zlib
  ];

  # The downloaded Python expects /etc/ssl/cert.pem, which is absent on NixOS.
  profile = ''
    export SSL_CERT_FILE="''${SSL_CERT_FILE:-${cacert}/etc/ssl/certs/ca-bundle.crt}"
  '';

  runScript = writeShellScript "chatgpt-launch" ''
    set -euo pipefail
    : "''${HOME:?HOME must be set to launch ChatGPT}"
    resources=${unwrapped}/lib/chatgpt/resources
    cacheRoot="''${XDG_CACHE_HOME:-$HOME/.cache}/chatgpt-nix"
    cachedResources="$cacheRoot/${builtins.baseNameOf unwrapped}"

    # The app copies plugins and edits their manifests. Store permissions would make those copies read-only.
    # Lock and atomically publish one writable copy per payload, without copying the large native runtimes.
    (
      umask 077
      mkdir -p "$cacheRoot"
      exec 9>"$cacheRoot/.lock"
      flock 9
      if [ ! -d "$cachedResources" ]; then
        staging=$(mktemp -d "$cacheRoot/.resources.XXXXXX")
        trap 'rm -rf -- "$staging"' EXIT
        cp -R "$resources/plugins" "$staging/plugins"
        chmod -R u+w "$staging/plugins"
        for resource in "$resources"/*; do
          name=$(basename "$resource")
          if [ "$name" != plugins ]; then
            ln -s "$resource" "$staging/$name"
          fi
        done
        mv -T "$staging" "$cachedResources"
        trap - EXIT
      fi
    )

    export CODEX_ELECTRON_BUNDLED_PLUGINS_RESOURCES_PATH="$cachedResources"
    exec ${unwrapped}/lib/chatgpt/ChatGPT "$@"
  '';

  extraInstallCommands = ''
    mkdir -p "$out/share"
    cp -R ${unwrapped}/share/applications ${unwrapped}/share/doc ${unwrapped}/share/pixmaps "$out/share/"
    chmod u+w "$out/share/applications/chatgpt.desktop"
    substituteInPlace "$out/share/applications/chatgpt.desktop" \
      --replace-fail 'Exec=chatgpt %U' "Exec=$out/bin/chatgpt %U"
    ${lib.getExe' desktop-file-utils "desktop-file-validate"} "$out/share/applications/chatgpt.desktop"
  '';

  passthru = {
    inherit (unwrapped) src;
    inherit unwrapped;
    updateScript = lib.getExe (writeShellApplication {
      name = "update-chatgpt";
      runtimeInputs = [ curl python3 ];
      text = "exec python3 pkgs/chatgpt/update.py";
    });
  };
}
