{
  lib,
  stdenv,
  fetchurl,
}:
stdenv.mkDerivation rec {
  pname = "PaperTweaks";
  version = "0.5.0-beta.1";
  owner = "MC-Machinations";

  preferLocalBuild = true;

  dontUnpack = true;
  dontConfigure = true;

  installPhase = let
    jar = fetchurl {
      url = "https://github.com/${owner}/${pname}/releases/download/v${version}/PaperTweaks.jar";
      sha256 = "1rjxbs1sm8r6rn8cy0rxfpl90q2wjh53448gw5pld236fzdc2awf";
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
