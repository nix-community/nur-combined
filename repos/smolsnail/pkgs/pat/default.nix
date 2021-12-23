{ buildPythonPackage, fetchPypi, lib }:

buildPythonPackage rec {
  pname = "patcat";
  version = "2021.12.23";
  src = fetchPypi {
    inherit pname version;
    sha256 = "16d3bd860777cc60c3613a86e3cab690e9526fd92604e985c1149aae6a85307c";
  };
  meta = with lib; {
    description = "Outputs text with rainbow colors.";
    longDescription = ''
      Pat is a Python script that prints text from stdin or files with
      pastel, rainbow colors.
    '';
    homepage = "https://gitdab.com/elle/pat";
    license = licenses.unlicense;
    platforms = platforms.all;
  };
}
