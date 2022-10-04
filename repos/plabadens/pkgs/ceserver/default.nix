{ stdenv
, lib
, fetchFromGitHub
, zlib
}:

stdenv.mkDerivation rec {
  pname = "ceserver";
  version = "7.4";

  src = fetchFromGitHub {
    owner = "cheat-engine";
    repo = "cheat-engine";
    rev = version;
    sha256 = "sha256-9f4svWpH6kltLQL4w58YPQklLAuLAHMXoVAa4h0jlFk=";
  };

  sourceRoot = "source/Cheat Engine/ceserver";

  buildInputs = [
    zlib
  ];

  makeFlags = [ "-C gcc" ];

  installPhase = ''
    install -D -m755 gcc/ceserver $out/bin/ceserver
  '';

  meta = with lib; {
    description = "Graphs the disk IO in a linux terminal";
    homepage = "https://github.com/stolk/diskgraph";
    license = licenses.mit;
    maintainers = with maintainers; [ plabadens ];
  };
}
