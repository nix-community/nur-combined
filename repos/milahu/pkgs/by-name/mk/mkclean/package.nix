{
  lib,
  stdenv,
  matroska-foundation,
}:

stdenv.mkDerivation rec {
  pname = "mkclean";
  inherit (matroska-foundation) version;
  buildCommand = ''
    mkdir -p $out/bin
    ln -s ${matroska-foundation}/bin/${pname} $out/bin
  '';
  meta = matroska-foundation.meta // {
    description = "clean and optimize Matroska and WebM files";
  };
}
