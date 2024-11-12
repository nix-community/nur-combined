{ lib, stdenv, fetchFromGitHub, cmake, pkg-config, glfw, curl, jansson }:

let
  microsoft-gsl = fetchFromGitHub {
    owner = "microsoft";
    repo = "GSL";
    rev = "v4.0.0";
    hash = "sha256-cXDFqt2KgMFGfdh6NGE+JmP4R0Wm9LNHM0eIblYe6zU=";
  };
  imgui = fetchFromGitHub {
    owner = "ocornut";
    repo = "imgui";
    rev = "v1.91.4";
    hash = "sha256-6j4keBOAzbBDsV0+R4zTNlsltxz2dJDGI43UIrHXDNM=";
  };
in
stdenv.mkDerivation rec {
  pname = "ftpd";
  version = "3.2.0";

  src = fetchFromGitHub {
    owner = "mtheall";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-Ewv9uCGjIUW+lJszJAmOyzdgSfBNXR9U8t7k0ceM4IM=";
  };

  cmakeFlags = [
    "-DFETCHCONTENT_SOURCE_DIR_GSL=${microsoft-gsl}"
    "-DFETCHCONTENT_SOURCE_DIR_IMGUI=${imgui}"
  ];

  installPhase = "
    mkdir $out/bin -p
    cp ftpd $out/bin/
  ";

  buildInputs = [ glfw curl jansson ];
  nativeBuildInputs = [ cmake pkg-config ];
}
