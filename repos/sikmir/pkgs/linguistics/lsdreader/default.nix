{
  lib,
  python3Packages,
  fetchFromGitHub,
}:

python3Packages.buildPythonApplication rec {
  pname = "lsdreader";
  version = "0.2.15";

  src = fetchFromGitHub {
    owner = "sv99";
    repo = "lsdreader";
    rev = "v${version}";
    hash = "sha256-8DYPFUmhgA4mxaliPjbPkywyJUwrl3J034scmFGE9no=";
  };

  doCheck = false;

  meta = with lib; {
    description = "Decompile Lingvo LSD dictionary to DSL";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
  };
}
