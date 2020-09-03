{ stdenv, fetchurl }:
let
  inherit (stdenv.hostPlatform) system;
  throwSystem = throw "Unsupported system: ${system}";

  pname = "pvs-studio";
  version = "7.09.41189.57";

  suffix = {
    x86_64-linux = "x86_64";
    x86_64-darwin = "macos";
  }.${system} or throwSystem;
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchurl {
    url = "https://files.viva64.com/pvs-studio-${version}-${suffix}.tgz";
    sha256 = {
      x86_64-linux = "1zmdw0yldh9jmb5q901w3jfx0dw79qw5hw991yds0r2ys6wx0az9";
      x86_64-darwin = "09ak7ima1a6jka0rkmaqpk7sv423jdffgwjxby5gccphzh209xr1";
    }.${system} or throwSystem;
  };

  installPhase = "./install.sh $out";

  meta = with stdenv.lib; {
    description = "Static code analyzer for C, C++";
    homepage = "https://www.viva64.com/en/pvs-studio/";
    license = licenses.unfree;
    maintainers = [ maintainers.sikmir ];
    platforms = [ "x86_64-linux" "x86_64-darwin" ];
    skip.ci = true;
  };
}
