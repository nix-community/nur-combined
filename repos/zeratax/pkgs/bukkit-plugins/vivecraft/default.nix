{
  lib,
  stdenv,
  fetchurl,
}:
stdenv.mkDerivation rec {
  pname = "vivecraft";
  version = "121";
  owner = "jrbudda";

  preferLocalBuild = true;

  dontUnpack = true;
  dontConfigure = true;

  installPhase = let
    jar = fetchurl {
      url = "https://github.com/${owner}/Vivecraft_Spigot_Extensions/releases/download/${version}/Vivecraft_Spigot_Extensions.1.21r1.zip";
      sha256 = "07bm2z7nrxsa46myypawawnb9m7f6p8yyyhspv95b9phvhslgm0y";
    };
  in ''
    mkdir -p $out
    cp ${jar} $out/${pname}.jar
  '';

  meta = with lib; {
    homepage = "https://www.vivecraft.org";
    description = "Spigot plugin for Vivecraft, the VR mod for Java Minecraft.";
    maintainers = with maintainers; [zeratax];
  };
}
