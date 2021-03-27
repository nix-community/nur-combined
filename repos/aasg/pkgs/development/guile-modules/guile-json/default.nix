{ stdenv, lib, fetchzip, pkgconfig, guile }:

stdenv.mkDerivation rec {
  pname = "guile-json";
  version = "4.5.2";

  src = fetchzip {
    url = "mirror://savannah/${pname}/${pname}-${version}.tar.gz";
    hash = "sha256-OnqXvTvhMjCFQmBqcNz3AOYw3Fx2e0WTyw6jp1fDuwQ=";
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
