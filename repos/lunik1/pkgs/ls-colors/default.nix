{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:

stdenvNoCC.mkDerivation rec {
  pname = "ls-colors";
  version = "unstable-2025-06-06";

  src = fetchFromGitHub {
    owner = "trapd00r";
    repo = "LS_COLORS";
    rev = "810ce8cac886ac50e75d84fb438b549a1f9478ee";
    sha256 = "sha256-MMzNknuELhpSkvcPgCL2Pp5A6DZrLajkz8qLphSNbjY=";
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
