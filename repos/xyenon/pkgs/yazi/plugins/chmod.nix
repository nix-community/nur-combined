{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  unstableGitUpdater,
}:

stdenvNoCC.mkDerivation {
  pname = "chmod";
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

    cp -r chmod.yazi $out

    runHook postInstall
  '';

  passthru.updateScript = unstableGitUpdater { };

  meta = with lib; {
    description = "Execute chmod on the selected files to change their mode";
    homepage = "https://github.com/yazi-rs/plugins/tree/main/chmod.yazi";
    license = licenses.mit;
    maintainers = with maintainers; [ xyenon ];
  };
}
