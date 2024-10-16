{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  unstableGitUpdater,
}:

stdenvNoCC.mkDerivation {
  pname = "git";
  version = "0-unstable-2024-10-15";

  src = fetchFromGitHub {
    owner = "yazi-rs";
    repo = "plugins";
    rev = "7458b6c791923d519298df6fef67728f4d19e560";
    hash = "sha256-TO6omlE92wO4bTKWWjsXBxTc1aeh6jreYI1xudF9/wo=";
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
