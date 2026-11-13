{
  lib,
  stdenv,
  stdenvNoCC,
  fetchurl,
  buildFHSEnv,
  writeShellScript,
  makeDesktopItem,
  dpkg,
}:
let
  version = "8.9.7";
  src = fetchurl {
    url = "http://wppkg.baidupcs.com/issue/netdisk/Linuxguanjia/${version}/baidunetdisk_${version}_amd64.deb";
    hash = "sha256-bApd9P6Q9/GqXgfppwROPk0bbMqnvqvcH3+cwl+jsxw=";
  };
  unwrapped = stdenvNoCC.mkDerivation {
    pname = "baidunetdisk-unwrapped";
    inherit version src;
    nativeBuildInputs = [ dpkg ];
    dontUnpack = true;
    dontFixup = true;
    installPhase = ''
      runHook preInstall
      dpkg-deb -x "$src" deb-root
      mkdir -p "$out/opt/baidunetdisk"
      cp -a deb-root/opt/baidunetdisk/. "$out/opt/baidunetdisk/"
      runHook postInstall
    '';
  };
  legacyGtkmm =
    (import (builtins.fetchTree {
      type = "github";
      owner = "NixOS";
      repo = "nixpkgs";
      rev = "fa1373130d5a21c040a47c5dbe1913d59ed91808";
      narHash = "sha256-HzgjxrLY4AEc0044ZuM5CHbLSWLZgDlay1idmzvvpJs=";
    }) { system = stdenv.hostPlatform.system; }).gtkmm2;
  sigc = builtins.filter (pkg: lib.getName pkg == "libsigc++") (
    lib.concatMap (pkg: pkg.propagatedBuildInputs or [ ]) legacyGtkmm.propagatedBuildInputs
  );
  desktopItem = makeDesktopItem {
    name = "baidunetdisk";
    desktopName = "Baidu Netdisk";
    exec = "baidunetdisk %U";
    terminal = false;
    icon = "baidunetdisk";
    startupWMClass = "baidunetdisk";
    comment = "Baidu Netdisk";
    mimeTypes = [ "x-scheme-handler/baiduyunguanjia" ];
    categories = [ "Network" ];
    extraConfig = {
      "Name[zh_CN]" = "百度网盘";
      "Name[zh_TW]" = "百度網盤";
      "Comment[zh_CN]" = "百度网盘";
      "Comment[zh_TW]" = "百度網盤";
    };
  };

in
buildFHSEnv {
  pname = "baidunetdisk";
  inherit version src;
  executableName = "baidunetdisk";
  targetPkgs =
    pkgs:
    (map (pkg: pkg.out) (
      builtins.filter (pkg: lib.getName pkg != "gtk+") (legacyGtkmm.propagatedBuildInputs ++ sigc)
    ))
    ++ (with pkgs; [
      legacyGtkmm
      alsa-lib
      at-spi2-core
      cairo
      cups
      dbus
      expat
      glib
      gtk2
      gtk3
      libappindicator
      libdbusmenu
      libdrm
      libgbm
      libglvnd
      libpulseaudio
      libx11
      libxcb
      libxcomposite
      libxdamage
      libxext
      libxfixes
      libxkbcommon
      libxrandr
      libxtst
      libxi
      libxcursor
      libxt
      libxinerama
      libxrender
      nspr
      nss
      pango
      stdenv.cc.cc.lib
      udev
      vulkan-loader
      wayland
      xdg-utils
    ]);
  multiPkgs = _: [ ];
  runScript = writeShellScript "baidunetdisk-launcher" ''
    export LD_LIBRARY_PATH="${unwrapped}/opt/baidunetdisk''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
    exec ${unwrapped}/opt/baidunetdisk/baidunetdisk --no-sandbox "$@"
  '';
  extraInstallCommands = ''
    mkdir -p "$out/share/applications"
    cp ${desktopItem}/share/applications/*.desktop "$out/share/applications/"
    install -Dm644 ${unwrapped}/opt/baidunetdisk/baidunetdisk.svg "$out/share/icons/hicolor/scalable/apps/baidunetdisk.svg"
  '';
  passthru.updateScript = [ (toString ./update.sh) ];
  meta = {
    description = "Baidu Netdisk";
    homepage = "https://pan.baidu.com/";
    platforms = [ "x86_64-linux" ];
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    mainProgram = "baidunetdisk";
  };
}
