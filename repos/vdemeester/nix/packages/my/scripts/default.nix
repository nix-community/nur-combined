{ stdenv }:

stdenv.mkDerivation {
  name = "vde-scripts-0.4";
  builder = ./builder.sh;
  src = ./.;
}
