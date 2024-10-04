{
  lib,
  stdenv,
  fetchurl,
  pkgs,
}:
stdenv.mkDerivation rec {
  pname = "Vivecraft_Spigot_Extensions";
  version = "121";
  owner = "jrbudda";

  preferLocalBuild = true;

  dontConfigure = true;

  src = fetchurl {
    url = "https://github.com/${owner}/${pname}/releases/download/${version}/${pname}.1.21r1.zip";
    sha256 = "07bm2z7nrxsa46myypawawnb9m7f6p8yyyhspv95b9phvhslgm0y";
  };

  unpackPhase = ''
    ${pkgs.unzip}/bin/unzip $src
  '';

  installPhase = ''
    mkdir -p $out
    cp ${pname}.jar $out/${pname}.jar
  '';

  meta = with lib; {
    homepage = "https://www.vivecraft.org";
    description = "Spigot plugin for Vivecraft, the VR mod for Java Minecraft.";
    maintainers = with maintainers; [zeratax];
  };
}
