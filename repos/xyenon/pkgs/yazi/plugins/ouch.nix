{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  unstableGitUpdater,
}:

stdenvNoCC.mkDerivation {
  pname = "ouch";
  version = "0.4.0-unstable-2024-12-09";

  src = fetchFromGitHub {
    owner = "ndtoan96";
    repo = "ouch.yazi";
    rev = "b8698865a0b1c7c1b65b91bcadf18441498768e6";
    hash = "sha256-eRjdcBJY5RHbbggnMHkcIXUF8Sj2nhD/o7+K3vD3hHY=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    cp -r . $out

    runHook postInstall
  '';

  passthru.updateScript = unstableGitUpdater { tagPrefix = "v"; };

  meta = with lib; {
    description = "A Yazi plugin to preview archives";
    homepage = "https://github.com/ndtoan96/ouch.yazi";
    license = licenses.mit;
    maintainers = with maintainers; [ xyenon ];
  };
}
