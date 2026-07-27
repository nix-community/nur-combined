{
  lib,
  stdenv,
  fetchurl,
  fetchgit,
  fetchFromGitHub,
  dockerTools,
  gettext,
}:

let
  sources = import ../../_sources/generated.nix {
    inherit
      fetchurl
      fetchgit
      fetchFromGitHub
      dockerTools
      ;
  };
in
stdenv.mkDerivation {
  inherit (sources.cockpit-machines) pname version src;

  nativeBuildInputs = [ gettext ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/cockpit/machines
    cp -r dist/* $out/share/cockpit/machines
    mkdir -p $out/share/metainfo
    msgfmt --xml -d po \
      --template org.cockpit_project.machines.metainfo.xml \
      -o $out/share/metainfo/org.cockpit_project.machines.metainfo.xml
    runHook postInstall
  '';

  postFixup = ''
    if [ -f $out/share/cockpit/machines/index.js.gz ]; then
      gunzip $out/share/cockpit/machines/index.js.gz
      sed -i "s#/usr/bin/python3#/usr/bin/env python3#ig" $out/share/cockpit/machines/index.js
      sed -i "s#/usr/bin/pwscore#/usr/bin/env pwscore#ig" $out/share/cockpit/machines/index.js
      gzip -9 $out/share/cockpit/machines/index.js
    fi
  '';

  meta = with lib; {
    description = "Cockpit UI for virtual machines";
    license = licenses.lgpl21;
    homepage = "https://github.com/cockpit-project/cockpit-machines";
    platforms = platforms.linux;
    maintainers = with maintainers; [ nyadiia ];
  };
}
