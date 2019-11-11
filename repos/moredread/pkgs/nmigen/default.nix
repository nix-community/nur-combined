{ fetchFromGitHub, python3Packages, yosys, nextpnr, icestorm, symbiyosys }:

# TODO: needs cleanup and meta
python3Packages.buildPythonApplication rec {
  pname = "nmigen";
  version = "0.1";
  nativeBuildInputs = [
    python3Packages.setuptools_scm
  ];
  prePatch = ''
    substituteInPlace setup.py --replace "setuptools_scm" ""
  '';
  checkInputs = [
    yosys
    nextpnr
    icestorm
    symbiyosys
  ];
  doCheck = false;
  propagatedBuildInputs = [
    python3Packages.pyvcd
    python3Packages.bitarray
    python3Packages.jinja2
  ];
  src = fetchFromGitHub {
    owner = "m-labs";
    repo = "nmigen";
    rev = "v${version}";
    sha256 = "0vz0z26lpn299xvhvhp6phfjfz11k9his85hxvd9almjxkghni8l";
  };
  # give a hint to setuptools_scm on package version
  preBuild = ''
    export SETUPTOOLS_SCM_PRETEND_VERSION="${version}"
  '';
}
