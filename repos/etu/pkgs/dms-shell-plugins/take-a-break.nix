{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "dms-take-a-break";
  version = "1.5.0-unstable-2026-09-14";

  src = fetchFromGitHub {
    owner = "hthienloc";
    repo = "dms-take-a-break";
    rev = "a35c114f364cd02f7500dbdf9caa145ee1520364";
    hash = "sha256-h50O0LRjtI7fGzgtZzx5OLVsI5cd1mJQ5NjjSQlPc7E=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r . $out/
  '';

  meta = with lib; {
    description = "DankMaterialShell gentle companion widget that reminds you to rest your eyes with short and long breaks";
    homepage = "https://github.com/hthienloc/dms-take-a-break";
    license = licenses.mit;
    maintainers = [maintainers.etu];
    platforms = platforms.all;
  };
}
