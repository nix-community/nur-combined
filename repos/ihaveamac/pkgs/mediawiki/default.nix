# based on: https://github.com/NixOS/nixpkgs/blob/9ca3f649614213b2aaf5f1e16ec06952fe4c2632/pkgs/servers/web-apps/mediawiki/default.nix

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

  postPatch = ''
    sed -i 's|$vars = Installer::getExistingLocalSettings();|$vars = null;|' includes/installer/CliInstaller.php
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

  meta = with lib; {
    inherit knownVulnerabilities;
    description = "The collaborative editing software that runs Wikipedia${lib.optionalString core " (without bundled extensions)"}";
    license = licenses.gpl2Plus;
    homepage = "https://www.mediawiki.org/";
    platforms = platforms.all;
  };
}
