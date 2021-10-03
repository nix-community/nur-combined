{ buildPythonPackage, fetchPypi, lib }:

buildPythonPackage rec {
  pname = "patcat";
  version = "2021.9.10.2";
  src = fetchPypi {
    inherit pname version;
    sha256 = "9aa47bfb62410b90e8363ffafe83a1e10d9343e17dfb3c46f523d3aa37ca44d1";
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
