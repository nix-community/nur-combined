{ libva, fetchFromGitHub, stdenv, lib, gcc13Stdenv, autoPatchelfHook, fetchurl
, libsForQt5, SDL2, gtk3, libvdpau }:

let
  # undefined symbol: _ZN7QWidget15controllerEventEP16QControllerEvent, version Qt_5
  qt = builtins.fetchTarball {
    url = "https://archive.org/download/steamlink-qt-5.14.1.tar/steamlink-qt-5.14.1.tar.gz";
    sha256 = "sha256:1bdp43aj9k2ff21x82yiw68yikwp7f4v2aws09ad8jq7g94kbgl9";
  };
  # CVAAPIAccelX11: vaPutSurface() failed: unknown libva error
  libva' = libva.overrideAttrs (oldAttrs: rec {
    version = "2.19.0";

    src = fetchFromGitHub {
      owner  = "intel";
      repo = "libva";
      rev = version;
      sha256 = "sha256-M6mAHvGl4d9EqdkDBSxSbpZUCUcrkpnf+hfo16L3eHs=";
    };
  });
  desktopItems = fetchFromGitHub {
    owner = "flathub";
    repo = "com.valvesoftware.SteamLink";
    rev = "59a69bd5f358fc28be05b7dacb281576cd655779";
    sha256 = "sha256-5fTcBTXaq1qMXDdmitdi0WsYQybUgiEUGoiPMCHdI9k=";
  };
in stdenv.mkDerivation rec {
  pname = "steamlink";
  version = "1.3.9.258";

  src = fetchurl {
    url = "https://repo.steampowered.com/steamlink/${version}/steamlink-${version}.tgz";
    sha256 = "sha256-9l5r81a+szj8zmdlNca3igj7ui5P4dvjAYmeIzbXwak=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];
  buildInputs = [
    libva' libsForQt5.qt5.qtbase SDL2 gtk3 libvdpau
  ];

  dontWrapQtApps = true;

  installPhase = ''
    mkdir $out
    mv bin lib $out
    # libstdc++.so.6: version `GLIBCXX_3.4.32' not found
    ln -s ${gcc13Stdenv.cc.cc.lib}/lib/{libstdc++.so.6,libgcc_s.so.1} $out/lib
    cp -r ${qt}/* $out/lib
    install -Dm0644 LICENSE.txt $out/share/licenses/steamlink/LICENSE.txt
    install -Dm0644 ${desktopItems}/icons/256/steamlink.png $out/share/icons/hicolor/256x256/apps/steamlink.png
    install -Dm0644 ${desktopItems}/com.valvesoftware.SteamLink.desktop $out/share/applications/steamlink.desktop
    substituteInPlace $out/share/applications/steamlink.desktop \
      --replace-fail /app/bin/steamlink steamlink \
      --replace-fail com.valvesoftware.SteamLink steamlink
  '';

  meta = with lib; {
    description = "Stream games from another computer with Steam";
    license = licenses.unfree;
    homepage = "https://store.steampowered.com/app/353380/Steam_Link/";
    platforms = [ "x86_64-linux" ];
    maintainers = with maintainers; [ ];
  };
}
