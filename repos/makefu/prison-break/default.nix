{pkgs, fetchFromGitHub}:
with pkgs.python3.pkgs;

buildPythonPackage rec {
  pname = "prison-break";
  version = "1.3.0";
  src = fetchFromGitHub {
    owner = "makefu";
    repo = pname;
    rev = version;
    sha256 = "sha256:1kjfwsz6wg5l9pa7484vq64f054qil0ksf6dh9arwspxwnzshgdh";
  };
  propagatedBuildInputs = [
    docopt
    requests
    beautifulsoup4
    (callPackage ./straight-plugin.nix {})
  ];
  checkInputs = [ black ];
}
