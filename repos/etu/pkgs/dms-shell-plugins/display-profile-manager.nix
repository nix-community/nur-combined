{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "dms-display-profile-manager";
  version = "0.2-unstable-2026-09-30";

  src = fetchFromGitHub {
    owner = "jankelemen";
    repo = "dank-display-profile-manager";
    rev = "df7e59e2e579bf26bb6071d274c87b2c6c6afced";
    hash = "sha256-FYtlcP8gg8wW2FNs2zV4zgt6bDj96rCNz5AUltlrVIA=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r . $out/
  '';

  meta = with lib; {
    description = "DankMaterialShell DankBar widget for selecting DMS output profiles";
    homepage = "https://github.com/jankelemen/dank-display-profile-manager";
    license = licenses.mit;
    maintainers = [maintainers.etu];
    platforms = platforms.all;
  };
}
