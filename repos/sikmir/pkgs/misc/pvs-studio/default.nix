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
  version = "7.21.64848.262";

  src = fetchurl {
    url = "https://cdn.pvs-studio.com/pvs-studio-${version}-${suffix}.tgz";
    hash = {
      x86_64-linux = "sha256-oOi7xQxv3I8hEnF62TSeA+ZIjIpabTN+ulMNImURECM=";
      x86_64-darwin = "sha256-BgONtKPE3Osd8g6ElebEyYUs9qFcuIU0HvsrdYSZEzc=";
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
}
