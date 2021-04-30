{ stdenv, lib, gfortran, fetchFromGitHub }:
stdenv.mkDerivation rec {
    pname = "packmol";
    version = "20.2.2";

    buildInputs = [ gfortran ];

    src = fetchFromGitHub {
      owner = "m3g";
      repo = pname;
      rev = "v${version}";
      sha256= "0pj6ah09zbj3lir628p8rbfbkq4wqnmvcyvq3rqgbc7w2vyslxrk";
    };

    dontConfigure = true;

    patches = [ ./MakeFortran.patch ];

    installPhase = ''
      mkdir -p $out/bin
      cp -p packmol $out/bin
    '';

    hardeningDisable = [ "format" ];

    meta = with lib; {
      description = "Generating initial configurations for molecular dynamics";
      license = licenses.mit;
      homepage = "http://m3g.iqm.unicamp.br/packmol/home.shtml";
      platforms = platforms.linux;
    };
  }
