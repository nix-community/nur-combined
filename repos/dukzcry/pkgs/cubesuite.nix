{ stdenvNoCC, lib, wrapWine, makeDesktopItem, fetchFromGitHub, unzip, ... }:

let
  version = "2.7.8";
  src = fetchFromGitHub {
    owner = "repos-holder";
    repo = "binaries";
    rev = "a52e76e19e596cb9fbe226515fc8130a7fed3ba4";
    sha256 = "sha256-WivF8GC9Lx/Y57eObyvi9PYhEmaf7A/0Wn6LbPqK1bI=";
  };
  bin = wrapWine {
    name = "cubesuite";
    executable = "$WINEPREFIX/drive_c/CubeSuite/CubeSuite.exe";
    firstrunScript = ''
      pushd "$WINEPREFIX/drive_c"
        ${unzip}/bin/unzip ${src}/CubeSuite+V${version}+for+Windows+OS.zip
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