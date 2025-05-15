{ stdenvNoCC, lib, wrapWine, makeDesktopItem, fetchurl, unzip, installShellFiles }:

let
  version = "2.8.2";
  src = fetchurl {
    url = "https://archive.org/download/cuvave-cubesuite/CubeSuite+V${version}+for+Windows+OS.zip";
    sha256 = "sha256-Lkcy0u6aApBD/KlMn6VnmvtqsyZ28X5RBQK1LZZ02vU==";
  };
  bin = (wrapWine {
    name = "cubesuite";
    executable = "$WINEPREFIX/drive_c/CubeSuite/CubeSuite.exe";
    firstrunScript = ''
      pushd "$WINEPREFIX/drive_c"
        ${lib.getExe unzip} ${src}
        # fix config import and export
        mkdir users/$USER/Desktop
      popd
    '';
  }) // { meta.mainProgram = "cubesuite"; };
  item = makeDesktopItem {
    name = "cubesuite";
    desktopName = "CubeSuite";
    type = "Application";
    exec = lib.getExe bin;
  };
in stdenvNoCC.mkDerivation rec {
  pname = "cubesuite";
  inherit version;

  dontUnpack = true;

  nativeBuildInputs = [ installShellFiles ];

  installPhase = ''
    installBin ${lib.getExe bin}
    install -Dm444 -t $out/share/applications ${item}/share/applications/cubesuite.desktop
  '';

  meta = with lib; {
    description = "Manage Cuvave MIDI controllers";
    license = licenses.free;
    homepage = "http://www.cuvave.com/appdownload";
    platforms = platforms.linux;
    maintainers = with maintainers; [ ];
    broken = wrapWine == null;
  };
}
