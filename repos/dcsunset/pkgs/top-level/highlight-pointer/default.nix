{ lib
, stdenv
, fetchFromGitHub
, libX11
, xorg
, libXext
}:

stdenv.mkDerivation rec {
  pname = "highlight-pointer";
  version = "1.1.3";

  src = fetchFromGitHub {
    owner = "swillner";
    repo = "highlight-pointer";
    rev = "refs/tags/v${version}";
    hash = "sha256-mz9gXAtrtSV0Lapx8xBOPljuF+HRgDaF2DKCDrHXQa8=";
  };

  buildInputs = [ libX11 libXext xorg.libXi xorg.libXfixes ];

  installPhase = ''
    mkdir -p $out/bin
    cp highlight-pointer $out/bin
  '';

  meta = with lib; {
    description = "Highlight mouse pointer/cursor using a dot";
    homepage = "https://github.com/swillner/highlight-pointer";
    changelog = "https://github.com/swillner/highlight-pointer/releases/tag/v${version}";
    license = licenses.mit;
    platforms = platforms.linux;
    mainProgram = "highlight-pointer";
  };
}
