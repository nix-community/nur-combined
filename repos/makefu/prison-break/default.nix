{pkgs, fetchFromGitHub}:
with pkgs.python3.pkgs;

buildPythonPackage rec {
  pname = "prison-break";
  version = "1.2.0";
  src = fetchFromGitHub {
    owner = "makefu";
    repo = pname;
    rev = version;
    sha256 = "07wy6f06vj9s131c16gw1xl1jf9gq5xiqia8awfb26s99gxlv7l9";
  };
  propagatedBuildInputs = [
    docopt
    requests
    beautifulsoup4
    (callPackage ./straight-plugin.nix {})
  ];
  checkInputs = [ black ];
}
