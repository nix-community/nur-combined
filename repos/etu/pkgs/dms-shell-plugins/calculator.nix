{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "dms-calculator";
  version = "0.3.3-unstable-2026-06-22";

  src = fetchFromGitHub {
    owner = "rochacbruno";
    repo = "DankCalculator";
    rev = "1db5865419a40a33171a475855a59e0b8bf7187f";
    hash = "sha256-j8C62+sevr6b+akzVSAqUVysIhb6Vbr8jnWcTXeOtE8=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r . $out/
  '';

  meta = with lib; {
    description = "DankMaterialShell launcher plugin that evaluates mathematical expressions and copies results to clipboard";
    homepage = "https://github.com/rochacbruno/DankCalculator";
    license = licenses.agpl3Only;
    maintainers = [maintainers.etu];
    platforms = platforms.all;
  };
}
