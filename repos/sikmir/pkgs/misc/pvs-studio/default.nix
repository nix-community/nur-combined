{
  lib,
  stdenv,
  fetchurl,
}:
let
  inherit (stdenv.hostPlatform) system;
  throwSystem = throw "Unsupported system: ${system}";

  suffix =
    {
      x86_64-linux = "x86_64";
      x86_64-darwin = "macos-x86_64";
    }
    .${system} or throwSystem;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "pvs-studio";
  version = "7.36.91321.455";

  src = fetchurl {
    url = "https://cdn.pvs-studio.com/pvs-studio-${finalAttrs.version}-${suffix}.tgz";
    hash =
      {
        x86_64-linux = "sha256-xrAUlott87qCiajVecKw9TvYx+rMDd5GeG1UI3udHqQ=";
        x86_64-darwin = "sha256-iv1okllOV3ht57BH9IHykwAYla/tEpkDhpvQeR4tm1c=";
      }
      .${system} or throwSystem;
  };

  installPhase = "sh ./install.sh $out";

  meta = {
    description = "Static code analyzer for C, C++";
    homepage = "https://www.viva64.com/en/pvs-studio/";
    license = lib.licenses.unfree;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = [
      "x86_64-linux"
      "x86_64-darwin"
    ];
    skip.ci = true;
  };
})
