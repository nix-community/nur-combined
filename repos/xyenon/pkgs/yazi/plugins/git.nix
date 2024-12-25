{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  unstableGitUpdater,
}:

stdenvNoCC.mkDerivation {
  pname = "git";
  version = "0-unstable-2024-12-24";

  src = fetchFromGitHub {
    owner = "yazi-rs";
    repo = "plugins";
    rev = "71c4fc2e6fa1d6f70c85bf525842d6888d1ffa46";
    hash = "sha256-X3R5bsnzGv1TVXOKdhAyspDMguVAyc9tvCxJlypUUAA=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    cp -r git.yazi $out

    runHook postInstall
  '';

  passthru.updateScript = unstableGitUpdater { };

  meta = with lib; {
    description = "Show the status of Git file changes as linemode in the file list";
    homepage = "https://github.com/yazi-rs/plugins/tree/main/git.yazi";
    license = licenses.mit;
    maintainers = with maintainers; [ xyenon ];
  };
}
