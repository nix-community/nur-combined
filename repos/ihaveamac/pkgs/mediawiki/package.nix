# based on: https://github.com/NixOS/nixpkgs/blob/d407951447dcd00442e97087bf374aad70c04cea/pkgs/by-name/me/mediawiki/package.nix

{
  lib,
  stdenvNoCC,
  fetchurl,
  nixosTests,
  version,
  hash,
  core ? false,
  knownVulnerabilities ? [ ],
}:

stdenvNoCC.mkDerivation rec {
  pname = "mediawiki${lib.optionalString core "-core"}";
  inherit version;
  preferLocalBuild = true;

  src = fetchurl {
    url = "https://releases.wikimedia.org/mediawiki/${lib.versions.majorMinor version}/mediawiki${lib.optionalString core "-core"}-${version}.tar.gz";
    inherit hash;
  };

  # the case in "installer" changed with 1.46.0, so i use * to capture both
  postPatch = ''
    substituteInPlace includes/*nstaller/CliInstaller.php \
      --replace-fail '$vars = Installer::getExistingLocalSettings();' '$vars = null;'
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/mediawiki
    cp -r * $out/share/mediawiki
    echo "<?php
      return require(getenv('MEDIAWIKI_CONFIG'));
    ?>" > $out/share/mediawiki/LocalSettings.php

    runHook postInstall
  '';

  passthru.tests = {
    inherit (nixosTests.mediawiki) mysql postgresql;
  };

  meta = {
    inherit knownVulnerabilities;
    description = "The collaborative editing software that runs Wikipedia${lib.optionalString core " (without bundled extensions)"}";
    license = lib.licenses.gpl2Plus;
    homepage = "https://www.mediawiki.org/";
    platforms = lib.platforms.all;
  };
}
