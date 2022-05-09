{ stdenv
, fetchFromGitHub
, ...
} @ args:

stdenv.mkDerivation rec {
  pname = "nbfc-lantian";
  version = "7669188fcd6a6391c2f53d27e65b8031f17c58e3";
  src = fetchFromGitHub {
    owner = "xddxdd";
    repo = "nbfc-linux";
    rev = version;
    sha256 = "sha256-cpLc6OYyXUwLz0gxq+HF9w9DVhe7M2qLqss6sizgQLY=";
  };

  makeFlags = [ "PREFIX=${placeholder "out"}" ];
}
