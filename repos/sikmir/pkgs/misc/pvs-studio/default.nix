{ lib, stdenv, fetchurl }:
let
  inherit (stdenv.hostPlatform) system;
  throwSystem = throw "Unsupported system: ${system}";

  suffix = {
    x86_64-linux = "x86_64";
    x86_64-darwin = "macos";
  }.${system} or throwSystem;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "pvs-studio";
  version = "7.27.75620.346";

  src = fetchurl {
    url = "https://cdn.pvs-studio.com/pvs-studio-${finalAttrs.version}-${suffix}.tgz";
    hash = {
      x86_64-linux = "sha256-Jno4bnrgV4VS86sd2LcPJtGn7qo80mCA1htpiuFf/eQ=";
      x86_64-darwin = "sha256-T8i+slwpOOPKCLlZ0inz3WSAQNytZrysBGv5FA0IkqE=";
    }.${system} or throwSystem;
  };

  installPhase = "sh ./install.sh $out";

  meta = with lib; {
    description = "Static code analyzer for C, C++";
    homepage = "https://www.viva64.com/en/pvs-studio/";
    license = licenses.unfree;
    maintainers = [ maintainers.sikmir ];
    platforms = [ "x86_64-linux" "x86_64-darwin" ];
    skip.ci = true;
  };
})
