{ lib
, stdenv
, bash
, coreutils
, makeWrapper
, fetchFromGitHub
}:

stdenv.mkDerivation {
  pname = "katifetch";
  version = "13.1";

  src = fetchFromGitHub {
    owner = "ximimoments";
    repo = "katifetch";
    rev = "13.1"; 
    sha256 = "sha256-/k+bF76sr/OSGlr0m/li4VinQNU4mZsmEv8AhMTNivg=";
  };

  buildInputs = [ bash ];
  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    install -Dm755 katifetch.sh $out/bin/katifetch
    wrapProgram $out/bin/katifetch \
      --prefix PATH : ${lib.makeBinPath [ coreutils ]}
  '';

  meta = with lib; {
    description = "A lightweight system fetch script";
    homepage = "https://github.com/ximimoments/katifetch";
    license = licenses.mit;
    platforms = platforms.linux;
    mainProgram = "katifetch";
  };
}
