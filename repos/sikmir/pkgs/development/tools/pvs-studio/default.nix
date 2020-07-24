{ stdenv, fetchurl }:
let
  inherit (stdenv.hostPlatform) system;
  throwSystem = throw "Unsupported system: ${system}";

  pname = "pvs-studio";
  version = "7.08.39765.52";

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
      x86_64-linux = "04las9ykgrvmjnwnnyfz1m2mlnwf73r8kf8d7igdjqmffih5kxdi";
      x86_64-darwin = "01850inmxi30v9cz94ja0vyb12hq2f1kkfw231qzskhm3h92snfx";
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
