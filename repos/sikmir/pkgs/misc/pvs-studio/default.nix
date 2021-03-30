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
  version = "7.12.46137.116";

  src = fetchurl {
    url = "https://files.viva64.com/pvs-studio-${version}-${suffix}.tgz";
    sha256 = {
      x86_64-linux = "0vgr0whkczpzsjrpp3gf9ydvc98b7754r7xfb7wncklam8s6bwaz";
      x86_64-darwin = "1n6agfq39bm58dk23cd5fbf5w2wm8302fmxrhfldij7dj2fmbq4d";
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
