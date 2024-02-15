{ fetchFromGitHub, python, stdenv }:

let
  python' = python.withPackages (p: with p; [
    PyICU
    nose
    pillow
  ]);
in
stdenv.mkDerivation rec {
  pname = "ocrodjvu";
  version = "0.12";

  buildInputs = [ python' ];

  src = fetchFromGitHub {
    owner = "jwilk";
    repo = pname;
    rev = version;
    hash = "sha256-gE70BQsi8GDRr7hnVaqemuDnAbmehH92wKQwHiKd3AU=";
  };

  installFlags = [ "PREFIX=$(out)" ];

  doCheck = true;
  checkTarget = "test";
}
