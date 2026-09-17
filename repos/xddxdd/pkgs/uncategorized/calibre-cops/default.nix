{
  fetchurl,
  lib,
  nix-update-script,
  stdenv,
  unzip,
}:
let
  configFile = ./config_local.php;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "calibre-cops";
  version = "4.5.4";
  src = fetchurl {
    url = "https://github.com/mikespub-org/seblucas-cops/releases/download/${finalAttrs.version}/cops-${finalAttrs.version}-php84.zip";
    hash = "sha256-KSPecmpzyV/OSvkW4Skvesbw3qe/LnT9a6wZ655Py4o=";
  };
  unpackPhase = ''
    runHook preUnpack

    unzip $src

    runHook postUnpack
  '';

  nativeBuildInputs = [
    unzip
  ];

  installPhase = ''
    runHook preInstall

    mkdir $out
    cp -r * $out/
    cp ${configFile} $out/config/local.php

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };
  meta = {
    changelog = "https://github.com/mikespub-org/seblucas-cops/releases/tag/${finalAttrs.version}";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Web-based light alternative to Calibre content server / Calibre2OPDS to serve ebooks";
    homepage = "http://blog.slucas.fr/en/oss/calibre-opds-php-server";
    license = lib.licenses.gpl2Only;
  };
})
