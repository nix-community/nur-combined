{ stdenv }:

stdenv.mkDerivation {
  name = "vde-scripts-0.2";
  builder = ./builder.sh;
  src = ./.;
}
