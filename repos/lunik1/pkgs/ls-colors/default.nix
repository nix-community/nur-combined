{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:

stdenvNoCC.mkDerivation rec {
  pname = "ls-colors";
  version = "unstable-2024-12-20";

  src = fetchFromGitHub {
    owner = "trapd00r";
    repo = "LS_COLORS";
    rev = "81e2ebcdc2ed815d17db962055645ccf2125560c";
    sha256 = "sha256-ePs7UlgQqh3ptRXUNlY/BDa/1aH9q3dGa3h0or/e6Kk=";
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
