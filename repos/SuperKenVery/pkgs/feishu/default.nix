{ stdenv,pkgs,lib }:

let 
  version = "5.9.18";
in
pkgs.stdenv.mkDerivation rec {
  # Mostly copied from https://github.com/SuperKenVery/nixpkgs-hardenedlinux/blob/main/nix/pkgs/packages/toplevel/feishu/default.nix
  # But added libgcrypt
  
  # Thank you, hardened linux!
  pname = "feishu";

  inherit version;

  meta = with lib; {
    description = "Feishu, by bytedance";
    homepage = "https://www.feishu.cn/";
    license = licenses.unfree;
    platforms = [
      "x86_64-linux"
    ];
  };

  src = pkgs.fetchurl {
    url = "https://sf3-cn.feishucdn.com/obj/ee-appcenter/5db94058d7ad/Feishu-linux_x64-${version}.deb";
    sha256 = "sha256-/7KbWhhLAl1OTqRoqPaEpwZ6tb/UWGerw3Dlm+Y4ksc=";
  };

  buildInputs = with pkgs; [
    gsettings-desktop-schemas
    libdrm
    mesa.drivers.dev
    glib
    gtk3
    cairo
    atk
    libgcrypt
    gdk-pixbuf
    at-spi2-atk
    dbus
    dconf
    xorg.libX11
    xorg.libxcb
    xorg.libXi
    xorg.libXcursor
    xorg.libXdamage
    xorg.libXrandr
    xorg.libXcomposite
    xorg.libXext
    xorg.libXfixes
    xorg.libXrender
    xorg.libXtst
    xorg.libXScrnSaver
    xorg.libxshmfence
    nss
    nspr
    alsa-lib
    cups
    fontconfig
    expat
  ];
  nativeBuildInputs = with pkgs; [
    wrapGAppsHook
    autoPatchelfHook
    makeWrapper
    dpkg
  ];
  unpackPhase = "dpkg-deb --fsys-tarfile $src | tar -x --no-same-permissions --no-same-owner";
  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,share/feishu,lib}

    mv opt/bytedance/feishu/* $out/share/feishu
    mv usr/share/* $out/share/

    substituteInPlace $out/share/applications/bytedance-feishu.desktop  \
      --replace "/usr/bin/bytedance-feishu-stable %U" "$out/bin/feishu $U"

    runHook postInstall
  '';

  dontWrapGApps = true;

  runtimeLibs = pkgs.lib.makeLibraryPath [
    pkgs.libudev0-shim
    pkgs.glibc
    pkgs.libsecret
    pkgs.nss
  ];

  preFixup = ''
    makeWrapper $out/share/feishu/feishu $out/bin/feishu \
      --prefix LD_LIBRARY_PATH : "${runtimeLibs}" \
      "''${gappsWrapperArgs[@]}"
  '';
  enableParallelBuilding = true;
}