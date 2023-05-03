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
  version = "7.24.70333.311";

  src = fetchurl {
    url = "https://cdn.pvs-studio.com/pvs-studio-${finalAttrs.version}-${suffix}.tgz";
    hash = {
      x86_64-linux = "sha256-Kw0ZbtAwXJR3+/jh0xB6EtRDUOGRYnaJZXnf5v2nn6k=";
      x86_64-darwin = "sha256-bDcptyzbJ4YurS2bS4H6vW89J6MFBt+42IP3v88TVck=";
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
