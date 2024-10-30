{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  unstableGitUpdater,
}:

stdenvNoCC.mkDerivation {
  pname = "git";
  version = "0-unstable-2024-10-26";

  src = fetchFromGitHub {
    owner = "yazi-rs";
    repo = "plugins";
    rev = "ad52adf917d6dd679dbc2dcefa3a9384654bd1c7";
    hash = "sha256-UOSH8RM+6VkQqi14bwUdFUNm8CgbDRlNial9VevjYuU=";
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
