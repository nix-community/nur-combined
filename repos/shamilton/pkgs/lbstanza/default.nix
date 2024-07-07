{ lib
, stdenv
, fetchFromGitHub
, lbstanza-bin
, cmake
}:

stdenv.mkDerivation rec {
  pname = "lbstanza";
  version = "2023-04-20";

  src = fetchFromGitHub {
    owner = "StanzaOrg";
    repo = "lbstanza";
    rev = "c1c939a9c111bc280de8c9ef8dc1e08b75112cd5";
    sha256 = "sha256-G4jk0VHtBM7IyNMp2SpOJQmwHyC1OlN2jfALSUswN50=";
  };

  postPatch = ''
    patchShebangs scripts/*.sh
  '';

  preBuild = ''
    mkdir build
    export HOME=$(pwd)
    cat << EOF > .stanza
      install-dir = "${lbstanza-bin}"
      platform = linux
      aux-file = "mystanza.aux"
    EOF
  '';

  buildPhase = ''
    runHook preBuild
    ./scripts/make.sh stanza linux compile-clean
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir "$out"
    cp -r * "$out"
    mv "$out/lpkgs" "$out/pkgs"
    mv "$out/lstanza" "$out/bin/stanza"
    ln -s "$out/bin/stanza" "$out/stanza"
    runHook postInstall
  '';

  nativeBuildInputs = [ lbstanza-bin cmake ];
  dontUseCmakeConfigure = true;

  meta = with lib; {
    description = "L.B. Stanza Programming Language";
    license = licenses.mit;
    homepage = "http://lbstanza.org/";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
