{ stdenv, fetchurl }:
let
  inherit (stdenv.hostPlatform) system;
  throwSystem = throw "Unsupported system: ${system}";

  pname = "pvs-studio";
  version = "7.09.42228.74";

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
      x86_64-linux = "0m8h9ghhhqqakl5lks9hncswfr3w9f4gjsnspqak1h9wcgznzk53";
      x86_64-darwin = "1fcwvj9klhwlv6w5w7sx4brrw6xkx0w4hysprbzn89q6y6mraq9p";
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
