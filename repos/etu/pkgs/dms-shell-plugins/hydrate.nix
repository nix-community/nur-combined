{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "dms-hydrate";
  version = "0-unstable-2026-06-21";

  src = fetchFromGitHub {
    owner = "hthienloc";
    repo = "dms-hydrate";
    rev = "5a7059e9b95fe346d9ac60a95560d7c9790c92d1";
    hash = "sha256-9Sl2c3eQv0NnoXQBOa2HuJDc6DOGsHgJfTRBxCRilCo=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r . $out/
  '';

  meta = with lib; {
    description = "DankMaterialShell widget for water-drinking reminders and tracking";
    homepage = "https://github.com/hthienloc/dms-hydrate";
    license = licenses.mit;
    maintainers = [maintainers.etu];
    platforms = platforms.all;
  };
}
