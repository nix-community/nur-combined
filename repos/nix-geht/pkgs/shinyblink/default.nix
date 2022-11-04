{ lib, stdenv, pkgs, ...}:

let
  mkShinyFfUtil = description: derivargs: srcargs: stdenv.mkDerivation (rec {
    pname = srcargs.repo;
    src = pkgs.fetchFromGitHub ({
      owner = "shinyblink";
      rev = "v${derivargs.version}";
    } // srcargs);
    installFlags = [ "PREFIX=$(out)" ];

    meta = with lib; {
      inherit description;
      homepage = "https://github.com/shinyblink/${srcargs.repo}/";
      license = licenses.isc;
      platforms = platforms.unix;
      maintainers = with maintainers; [ vifino ];
    };
  } // derivargs);
in
{
  # Farbfeld Packages.
  ffshot = mkShinyFfUtil
    "farbfeld screenshot utility"
    { version = "1.0.0"; buildInputs = with pkgs.xorg; [ libxcb xcbutilimage ]; }
    { repo = "ffshot"; hash = "sha256-lPHPwieotSgA6qF3EGDZk+lME0rqglOnEreYLk0/oUY="; };

  ff-overlay = mkShinyFfUtil
    "overlay one farbfeld image on top of another"
    { version = "1.0.0"; }
    { repo = "ff-overlay"; hash = "sha256-E3vaZDj69X3tRqFxXMxZLaNwkhxsbtNodavab7ScLBo="; };

  ff-sort = mkShinyFfUtil
    "farbfeld pixel sorter"
    { version = "1.0.0"; }
    { repo = "ff-sort"; hash = "sha256-odUChDvivr+IyyvqpDQyrrxzIJe/Uge0K3ULx3SXdSk="; };

  ff-glitch = mkShinyFfUtil
    "farbfeld image glitcher"
    { version = "0.1.0"; }
    { repo = "ff-glitch"; hash = "sha256-V6OtjtLkRnsDXBQN18KRcLtEDSroglbz6moU7L1eoCk="; };

  ff-notext = mkShinyFfUtil
    "Tesseract OCR-based text removal on farbfeld images"
    { version = "0.1.0"; nativeBuildInputs = [ pkgs.pkg-config ]; buildInputs = [ pkgs.tesseract5 ]; }
    { repo = "ff-notext"; hash = "sha256-lAhpJLlpSRLzRG4xgs/Ka8ZA1G8mH0632edHOfn3ffk="; };
}
