{ stdenv
, fetchFromGitHub
, dmd
, sqlite
, curl
, pkgconfig
}:

stdenv.mkDerivation rec {
  name = "onedrive-${version}";
  version = "2.4.5";
  src = fetchFromGitHub {
    owner = "abraunegg";
    repo = "onedrive";
    rev = "v${version}";
    sha256 = "129hk2pl7xwsykzlady2b4ww3kc3vawfssvh53i7423jbzp95906";
  };
  buildInputs = [ dmd sqlite curl pkgconfig ];
}
