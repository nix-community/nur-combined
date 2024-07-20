{ lib
, stdenvNoCC
, fetchFromGitHub
}:

stdenvNoCC.mkDerivation rec {
  pname = "ls-colors";
  version = "unstable-2023-12-13";

  src = fetchFromGitHub {
    owner = "trapd00r";
    repo = "LS_COLORS";
    rev = "a283d79dcbb23a8679f4b1a07d04a80cab01c0ba";
    sha256 = "sha256-DT9WmtyJ/wngoiOTXMcnstVbGh3BaFWrr8Zxm4g4b6U=";
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
