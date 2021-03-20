{ stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  pname = "hass-smartbox";
  version = "0.1.0-pre";

  src = fetchFromGitHub {
    owner = "graham33";
    repo = pname;
    rev = "c50b657058003c521f294c0097aed6820226a7a7";
    sha256 = "1y83vjvvql2gisspjvcdxjaxr59v3jiig7j9l1p4cqby6y9ny1sm";
  };

  installPhase = ''
    mkdir -p $out
    cp -r * $out/
  '';

}
