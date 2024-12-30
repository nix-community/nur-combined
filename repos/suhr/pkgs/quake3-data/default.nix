{ stdenv, lib, fetchurl, requireFile }:

stdenv.mkDerivation rec {
  pname = "quake3-data";
  version = "1.11-6";  # FIXME

  src = requireFile rec {
    name = "pak0.pk3";
    message = "Please add pak0.pk3 to the nix store manually";
    sha256 = "7ce8b3910620cd50a09e4f1100f426e8c6180f68895d589f80e6bd95af54bcae";
  };

  buildCommand = ''
    mkdir -p $out/baseq3
    cp $src $out/baseq3/pak0.pk3
  '';

  preferLocalBuild = true;

  meta = with lib; {
    description = "Quake 3 Arena content (pak0.pk3)";
    license = licenses.unfree;
    platforms = platforms.all;
    maintainers = [ ];
  };
}
