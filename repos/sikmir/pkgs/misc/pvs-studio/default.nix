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
  version = "7.28.78353.377";

  src = fetchurl {
    url = "https://cdn.pvs-studio.com/pvs-studio-${finalAttrs.version}-${suffix}.tgz";
    hash = {
      x86_64-linux = "sha256-XZFehz46Fkka5J2tYE66yxZhUzDYSwYhT6M9QnumFac=";
      x86_64-darwin = "sha256-S8Tb5g+Dod9OAsL1+sv2CNt1a+aF6WfCUV4YeOIYp1k=";
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
