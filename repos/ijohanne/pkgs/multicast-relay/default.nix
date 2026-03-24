{ sources, pkgs, stdenv, ... }:
with pkgs;
stdenv.mkDerivation {
  name = "multicast-relay";
  buildInputs = [
    (python3.withPackages (ps: with ps; [
      netifaces
    ]))
  ];
  src = sources.multicast-relay;
  installPhase = ''
    mkdir -p $out/bin
    cp multicast-relay.py $out/bin/multicast-relay
    chmod +x $out/bin/multicast-relay
  '';
}
