{ lib
, stdenvNoCC
, fetchFromGitHub
}:

stdenvNoCC.mkDerivation rec {
  pname = "ls-colors";
  version = "unstable-2023-11-30";

  src = fetchFromGitHub {
    owner = "trapd00r";
    repo = "LS_COLORS";
    rev = "bcf78f74be4788ef224eadc7376ca780ae741e1e";
    sha256 = "sha256-gf7mXbtKIMGB4K7/M4OzsQLWNdHUaB/TMsC1sS0eBWw=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -Dm644 $src/LS_COLORS $out/share/ls-colors/LS_COLORS

    runHook postInstall
  '';

  meta = with lib; {
    description = "A collection of LS_COLORS definitions";
    homepage = "https://github.com/trapd00r/LS_COLORS";
    license = licenses.artistic1-cl8;
    maintainers = with maintainers; [ lunik1 ];
    platforms = platforms.all;
  };
}
