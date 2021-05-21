{ stdenv, fetchFromGitHub, lib }:

stdenv.mkDerivation rec {
  pname = "uwufetch";
  version = "1.4";

  src = fetchFromGitHub {
    owner = "TheDarkBug";
    repo = "uwufetch";
    rev = version;
    sha256 = "sha256-LlVcolm1sTcvi2iCoEYHz/+OSNQERGTsQ4sHs3QE4Ng=";
  };

  patches = [ ./makefile.diff ];

  preInstall = ''
    mkdir -p $out/bin
    mkdir -p $out/usr/lib
  '';

  installFlags = [ "DESTDIR=$(out)" "PREFIX=/bin" ];
}
