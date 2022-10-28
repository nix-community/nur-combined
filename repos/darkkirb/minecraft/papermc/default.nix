{
  stdenvNoCC,
  openjdk_headless,
  callPackage,
  lib,
  writeScript,
}: let
  paperJar = callPackage ./jar.nix {};
  versionInfo = builtins.fromJSON (builtins.readFile ./paper.json);
in
  stdenvNoCC.mkDerivation {
    preferLocalBuild = true;
    pname = "paper";
    version = "${versionInfo.version}.${toString versionInfo.build}";
    dontUnpack = true;
    dontConfigure = true;

    buildPhase = ''
      cat > minecraft-server << EOF
      #!/bin/sh
      exec ${openjdk_headless}/bin/java \$@ -jar $out/share/papermc/papermc.jar nogui
    '';

    installPhase = ''
      mkdir -p $out/share/papermc
      ln -s ${paperJar} $out/share/papermc/papermc.jar
      install -Dm555 -t $out/bin minecraft-server
    '';

    meta = {
      description = "High performance minecraft server";
      # This is a fun one because while papermc’s patches are released under the gpl, they apply patches to a proprietary binary which they then execute, so
      license = lib.licenses.gpl3;
      unfree = true;
    };
    passthru.updateScript = writeScript "update-paper" ''      #! /usr/bin/env nix-shell
      #! nix-shell -i bash -p curl jq

      curl -L https://papermc.io/api/v2/projects/paper/versions/1.19.2/builds | jq '{"version":.version, "build":.builds[-1].build, "name":.builds[-1].downloads.application.name, "sha256":.builds[-1].downloads.application.sha256}' > minecraft/papermc/paper.json
    '';
  }
