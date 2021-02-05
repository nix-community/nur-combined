{ lib, fetchPypi, python3Packages, setuptools, setuptools_scm, fire, toml }:

python3Packages.buildPythonApplication rec {
  pname = "colorpedia";
  version = "1.2.2";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1b19mlss6arc4sk0bsk6ssqc6advnzr2kq7snxrv8a6hki81ykm5";
  };

  nativeBuildInputs = [ setuptools_scm ];

  propagatedBuildInputs = [ fire toml setuptools ];

  meta = with lib; {
    description = "Command-line tool for looking up colors and palettes";
    homepage = "https://github.com/joowani/colorpedia";
    license = licenses.mit;
    platforms = platforms.unix;
    maintainers = [ ];
  };
}
