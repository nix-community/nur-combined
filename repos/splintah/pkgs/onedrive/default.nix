{ stdenv
, fetchFromGitHub
, dmd
, sqlite
, curl
, pkgconfig
}:

stdenv.mkDerivation rec {
  name = "onedrive-${version}";
  version = "2.3.11";
  src = fetchFromGitHub {
    owner = "abraunegg";
    repo = "onedrive";
    rev = "v${version}";
    sha256 = "08k5b3izqzk9mjjny5y47i3q5sl0w37xdqrhaacjxwm0jib9w0mh";
  };
  buildInputs = [ dmd sqlite curl pkgconfig ];
}
