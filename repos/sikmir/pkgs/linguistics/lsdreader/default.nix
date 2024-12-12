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
    tag = "v${version}";
    hash = "sha256-8DYPFUmhgA4mxaliPjbPkywyJUwrl3J034scmFGE9no=";
  };

  doCheck = false;

  meta = {
    description = "Decompile Lingvo LSD dictionary to DSL";
    homepage = "https://github.com/sv99/lsdreader";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
