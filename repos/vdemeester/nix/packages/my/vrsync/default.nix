{ stdenv }:

stdenv.mkDerivation rec {
  name = "vrsync";
  src = ./.;

  phases = [ "install" ];

  install = ''
    mkdir -p $out/bin
    cp $src/vrsync $out/bin
    chmod +x $out/bin/vrsync
  '';
}
