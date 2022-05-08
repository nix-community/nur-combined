{ stdenv
, fetchFromGitHub
, ...
} @ args:

stdenv.mkDerivation rec {
  pname = "nbfc-lantian";
  version = "2ef71f626f6af02c60893f94b42820fac4915edc";
  src = fetchFromGitHub {
    owner = "xddxdd";
    repo = "nbfc-linux";
    rev = version;
    sha256 = "sha256-9hm6vl0vG3B7FKphY6Sk7xUOpBF9PdJ3hOkJ6PodGIA=";
  };

  makeFlags = [ "PREFIX=${placeholder "out"}" ];
}
