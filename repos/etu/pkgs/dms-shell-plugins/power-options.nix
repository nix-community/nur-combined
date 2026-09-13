{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "dms-power-options";
  version = "0-unstable-2026-01-24";

  src = fetchFromGitHub {
    owner = "Nazahim";
    repo = "PowerOptions";
    rev = "95fa7949fd9614a21bcc7a14ff8cc917a7208cf8";
    hash = "sha256-PSlQIDWkteYaV0WPQlnm9wkc/8A8h1ZYxKgKSxlu+xo=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r . $out/
  '';

  meta = with lib; {
    description = "DankMaterialShell launcher plugin for power options like shutdown and reboot";
    homepage = "https://github.com/Nazahim/PowerOptions";
    license = licenses.mit;
    maintainers = [maintainers.etu];
    platforms = platforms.all;
  };
}
