{ stdenv, fetchFromGitHub, cmake }:
stdenv.mkDerivation rec {
  pname = "libevdevPlus";
  version = "0.1.0";

  nativeBuildInputs = [ cmake ];

  src = fetchFromGitHub {
    owner = "YukiWorkshop";
    repo = pname;
    rev = "v${version}";
    sha256 = "0kc8pcvgys1yv5prixqzpfklnn18mvnrlm13cr7npcs24k036q2w";
  };
}
