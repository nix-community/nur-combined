{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  unstableGitUpdater,
}:

stdenvNoCC.mkDerivation {
  pname = "chmod";
  version = "0-unstable-2024-09-14";

  src = fetchFromGitHub {
    owner = "yazi-rs";
    repo = "plugins";
    rev = "5e65389d1308188e5a990059c06729e2edb18f8a";
    hash = "sha256-XHaQjudV9YSMm4vF7PQrKGJ078oVF1U1Du10zXEJ9I0=";
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
