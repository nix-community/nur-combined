{
  fetchFromGitHub,
  lib,
  nix-update-script,
  stdenv,
}:
let
  configFile = ./config.inc.php;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "phppgadmin";
  version = "7.14.8-mod";
  src = fetchFromGitHub {
    owner = "ReimuHakurei";
    repo = "phppgadmin";
    tag = "v7.14.8-mod";
    hash = "sha256-rR4OVUa+K2qPjfgie+2+DSVySX+6gNZuRE0MVZV+Zgc=";
  };
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

  passthru.updateScript = nix-update-script { };
  meta = {
    changelog = "https://github.com/ReimuHakurei/phppgadmin/releases/tag/v${finalAttrs.version}";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Premier web-based administration tool for PostgreSQL";
    homepage = "https://github.com/phppgadmin/phppgadmin";
    license = lib.licenses.gpl2Only;
  };
})
