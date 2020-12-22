{ stdenv, fetchurl }:
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
  version = "7.11.44138.98";

  src = fetchurl {
    url = "https://files.viva64.com/pvs-studio-${version}-${suffix}.tgz";
    sha256 = {
      x86_64-linux = "1mrqfz5fbizafhsqfp67mrrhr6hfx7f53g9bixrxi1m1albgm062";
      x86_64-darwin = "0jz6rgk44c8r94s2sqb1d16rclh33rf1w8dcpy8h6csdxsbdnqk5";
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
