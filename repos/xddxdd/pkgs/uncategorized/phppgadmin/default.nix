{
  lib,
  stdenvNoCC,
  sources,
}:
let
  configFile = ./config.inc.php;
in
stdenvNoCC.mkDerivation (finalAttrs: {
  inherit (sources.phppgadmin) pname version src;

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r * $out/
    find $out -type f -exec chmod 644 {} +
    find $out -type d -exec chmod 755 {} +
    rm -rf $out/conf/config.inc.php-dist
    cp ${configFile} $out/conf/config.inc.php

    runHook postInstall
  '';

  meta = {
    changelog = "https://github.com/ReimuHakurei/phppgadmin/releases/tag/v${finalAttrs.version}";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Premier web-based administration tool for PostgreSQL";
    homepage = "https://github.com/phppgadmin/phppgadmin";
    license = lib.licenses.gpl2Only;
  };
})
