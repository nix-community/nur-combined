{
  stdenv,
  cmake,
  fetchFromGitHub,
}:
stdenv.mkDerivation rec {
  pname = "amgcl";
  version = "1.4.7";

  src = fetchFromGitHub {
    owner = "ddemidov";
    repo = "amgcl";
    rev = version;
    hash = "sha256-gODU6U5uwiZTt70wQv19bA1xJHymxdUpn3OtIIesOXw=";
  };
  nativeBuildInputs = [ cmake ];
}
