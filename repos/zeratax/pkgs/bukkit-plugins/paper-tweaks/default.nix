{
  lib,
  stdenv,
  fetchurl,
}:
stdenv.mkDerivation rec {
  pname = "PaperTweaks";
  version = "0.5.0";
  owner = "MC-Machinations";

  preferLocalBuild = true;

  dontUnpack = true;
  dontConfigure = true;

  installPhase = let
    jar = fetchurl {
      url = "https://github.com/${owner}/${pname}/releases/download/v${version}/PaperTweaks.jar";
      sha256 = "0f0v0x78m85d4vgsb9azispcbnf94n9injn6yyj0z6pj65llgf1g";
    };
  in ''
    mkdir -p $out
    cp ${jar} $out/${pname}.jar
  '';

  meta = with lib; {
    homepage = "https://github.com/MC-Machinations/PaperTweaks";
    description = "A better-performance replacement for the popular VanillaTweaks datapack collection.";
    maintainers = with maintainers; [zeratax];
  };
}
