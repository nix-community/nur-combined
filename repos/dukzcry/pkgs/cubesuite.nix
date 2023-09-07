{ stdenvNoCC, lib, wrapWine, makeDesktopItem, fetchurl, unzip }:

let
  version = "2.8.0";
  src = fetchurl {
    url = "https://archive.org/download/cuvave-cubesuite/CubeSuite+V${version}+for+Windows+OS.zip";
    sha256 = "sha256-/piT+Mu3KeQEVjCJRr9tdLgsZ9B9v0BnRaUvrD6I7IM=";
  };
  bin = wrapWine {
    name = "cubesuite";
    executable = "$WINEPREFIX/drive_c/CubeSuite/CubeSuite.exe";
    firstrunScript = ''
      pushd "$WINEPREFIX/drive_c"
        ${unzip}/bin/unzip ${src}
        # fix config import and export
        mkdir users/$USER/Desktop
      popd
    '';
  };
  item = makeDesktopItem {
    name = "cubesuite";
    desktopName = "CubeSuite";
    type = "Application";
    exec = ''${bin}/bin/cubesuite'';
  };
in stdenvNoCC.mkDerivation rec {
  pname = "cubesuite";
  inherit version;

  dontUnpack = true;

  installPhase = ''
    install -Dm755 -t $out/bin ${bin}/bin/cubesuite
    install -Dm444 -t $out/share/applications ${item}/share/applications/cubesuite.desktop
  '';

  meta = with lib; {
    description = "Manage Cuvave MIDI controllers";
    license = licenses.free;
    homepage = "http://www.cuvave.com/xznr";
    platforms = platforms.linux;
    maintainers = with maintainers; [ ];
    broken = wrapWine == null;
  };
}