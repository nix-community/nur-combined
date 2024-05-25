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
      x86_64-darwin = "macos";
    }
    .${system} or throwSystem;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "pvs-studio";
  version = "7.30.81094.390";

  src = fetchurl {
    url = "https://cdn.pvs-studio.com/pvs-studio-${finalAttrs.version}-${suffix}.tgz";
    hash =
      {
        x86_64-linux = "sha256-lUmNWB3dckCKV7EFZDPGZJseqfXksYtRwCXuIE3Jt64=";
        x86_64-darwin = "sha256-4ws+3ya+vvRWJwZw7sfygIe7d/h80ynoe2EMeCBdtks=";
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
