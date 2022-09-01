{ lib, stdenv, fetchurl }:
let
  inherit (stdenv.hostPlatform) system;
  throwSystem = throw "Unsupported system: ${system}";

  suffix = {
    x86_64-linux = "x86_64";
    x86_64-darwin = "macos";
  }.${system} or throwSystem;
in
stdenv.mkDerivation rec {
  pname = "pvs-studio";
  version = "7.20.63487.255";

  src = fetchurl {
    url = "https://cdn.pvs-studio.com/pvs-studio-${version}-${suffix}.tgz";
    hash = {
      x86_64-linux = "sha256-sFTE12t3unROXiY+W7pFKb0NVgIOVkElR/b260gw/Q0=";
      x86_64-darwin = "sha256-NBiWy/mEBSwcxZ2jiBcgQob2zfFgvJn9FF389xrSOLE=";
    }.${system} or throwSystem;
  };

  installPhase = "./install.sh $out";

  meta = with lib; {
    description = "Static code analyzer for C, C++";
    homepage = "https://www.viva64.com/en/pvs-studio/";
    license = licenses.unfree;
    maintainers = [ maintainers.sikmir ];
    platforms = [ "x86_64-linux" "x86_64-darwin" ];
    skip.ci = true;
  };
}
