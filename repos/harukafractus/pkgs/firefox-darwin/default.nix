{ edition, lib, stdenvNoCC, pkgs, fetchurl }:
let 
  sources = builtins.fromJSON (builtins.readFile ./sources.json);
in stdenvNoCC.mkDerivation rec {
  pname = "Firefox";
  inherit (sources."${edition}") version;
  src = fetchurl {
    name = "Firefox-${version}.dmg";
    inherit (sources."${edition}") url sha256;
  };

  nativeBuildInputs = [ pkgs.undmg ];
  sourceRoot = ".";
  installPhase = ''
    runHook preInstall
    
    mkdir -p "$out/Applications/Firefox.app" "$out/bin"
    cp -r ./* "$out/Applications/"
    ln -s "$out/Applications/Firefox.app/Contents/MacOS/firefox" "$out/bin/firefox"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Mozilla Firefox, free web browser (binary package)";
    homepage = "http://www.mozilla.com/en-US/firefox/";
    platforms = [ "x86_64-darwin" "aarch64-darwin" ];
  };
}
