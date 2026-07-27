{ stdenv }:

stdenv.mkDerivation rec {
  name = "vde-thinkpad";
  src = ./.;

  phases = [ "install" ];

  install = ''
    mkdir -p $out/bin
    cp $src/dock $out/bin
    chmod +x $out/bin/dock
  '';
}
