{
  lib,
  stdenv,
  fetchurl,
}:
stdenv.mkDerivation rec {
  pname = "VivecraftSpigot";
  version = "3.2.0";
  owner = "CJCrafter";

  preferLocalBuild = true;

  dontUnpack = true;
  dontConfigure = true;

  installPhase = let
    jar = fetchurl {
      url = "https://github.com/${owner}/${pname}/releases/download/v${version}/${pname}-${version}.jar";
      sha256 = "0s5a9bqykwpn8ym2lgj38r7yfji976w4cfi60zyzbnc89529c4bm";
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
