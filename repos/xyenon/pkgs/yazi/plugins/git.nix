{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  unstableGitUpdater,
}:

stdenvNoCC.mkDerivation {
  pname = "git";
  version = "0-unstable-2025-01-24";

  src = fetchFromGitHub {
    owner = "yazi-rs";
    repo = "plugins";
    rev = "8ed253716c60f3279518ce34c74ca053530039d8";
    hash = "sha256-xY2yVCLLcXRyFfnmyP6h5Fw+4kwOZhEOCWVZrRwXnTA=";
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
