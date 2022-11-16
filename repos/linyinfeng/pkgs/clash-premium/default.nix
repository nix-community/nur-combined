{ sources, stdenvNoCC, lib }:

let
  inherit (stdenvNoCC.hostPlatform) system;
  systems = [ "aarch64-linux" "i686-linux" "x86_64-darwin" "x86_64-linux" ];
in
stdenvNoCC.mkDerivation rec {
  pname = "clash-premium";
  inherit (sources."${pname}-${system}") version src;

  phases = [ "installPhase" ];
  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/clash-premium.gz
    gzip --decompress $out/bin/clash-premium.gz
    chmod +x $out/bin/clash-premium
  '';

  meta = with lib; {
    homepage = https://github.com/Dreamacro/clash;
    description = "Close-sourced pre-built Clash binary with TUN support and more";
    license = licenses.unfree;
    platforms = systems;
  };
}
