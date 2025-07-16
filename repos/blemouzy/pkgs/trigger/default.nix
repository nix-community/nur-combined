{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  inotify-tools,
}:

stdenvNoCC.mkDerivation rec {
  pname = "trigger";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "sharkdp";
    repo = "trigger";
    rev = "8d039e35010a18f4afba08093d7a2969d7df70de";
    sha256 = "sha256-4BwqRK9hAJKIYoguVHHzJW+O055g/nN+h77VqQ3CDYo=";
  };

  propagatedUserEnvPkgs = [ inotify-tools ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -D trigger $out/bin/trigger

    runHook postInstall
  '';

  meta = {
    description = "Run a user-defined command on file changes";
    homepage = "https://github.com/sharkdp/trigger";
    license = lib.licenses.mit;
    mainProgram = "trigger";
  };
}
