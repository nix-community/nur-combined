{
  lib,
  stdenv,
  pkgs,
  ...
}: {
  artsy = stdenv.mkDerivation {
    pname = "artsy";
    version = "0.0.0";

    src = pkgs.fetchFromGitHub {
      owner = "vifino";
      repo = "artsy";
      rev = "e30d1c4419d537e878d702486790f3179ae2c597";
      hash = "sha256-9s76LW47/Q3PIojJ/DKpIzSyKNnRcORmW+u51To374c=";
    };

    installFlags = ["PREFIX=$(out)"];

    meta = with lib; {
      description = "Some small programs that vaguely resemble some form of art";
      homepage = "https://github.com/vifino/artsy";
      license = licenses.isc;
      platforms = platforms.unix;
      maintainers = with maintainers; [vifino];
    };
  };
}
