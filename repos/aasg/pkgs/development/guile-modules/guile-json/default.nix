{ stdenv, lib, fetchzip, pkgconfig, guile }:

stdenv.mkDerivation rec {
  pname = "guile-json";
  version = "4.4.1";

  src = fetchzip {
    url = "mirror://savannah/${pname}/${pname}-${version}.tar.gz";
    hash = "sha256-aksK5rBzhD0/nUR4Am65u3HFrEeh7S47izFuY2czqXQ=";
  };

  nativeBuildInputs = [ pkgconfig ];
  buildInputs = [ guile ];

  doCheck = true;

  meta = with lib; {
    description = "JSON module for Guile";
    homepage = "https://savannah.nongnu.org/projects/guile-json/";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ AluisioASG ];
    platforms = platforms.gnu;
  };
}
