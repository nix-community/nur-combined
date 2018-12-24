{ stdenv, lib }:

stdenv.mkDerivation rec {
  name = "systemd-email";
  src = ./.;

  phases = [ "install" ];

  install = ''
    mkdir -p $out/bin
    cp $src/systemd-email $out/bin
    chmod +x $out/bin/systemd-email
  '';
}
