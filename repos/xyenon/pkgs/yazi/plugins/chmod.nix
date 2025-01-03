{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  unstableGitUpdater,
}:

stdenvNoCC.mkDerivation {
  pname = "chmod";
  version = "0-unstable-2025-01-02";

  src = fetchFromGitHub {
    owner = "yazi-rs";
    repo = "plugins";
    rev = "600614a9dc59a12a63721738498c5541c7923873";
    hash = "sha256-mQkivPt9tOXom78jgvSwveF/8SD8M2XCXxGY8oijl+o=";
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
