{ lib, fetchFromGitHub, buildPythonApplication }:

buildPythonApplication rec {
  pname = "dool";
  format = "other";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "scottchiefbaker";
    repo = "dool";
    rev = "v${version}";
    hash = "sha256-2J/5T/2rbdO+5lpi6WcuPd1kGIKYw/yqoHf8g6koGI8=";
  };

  dontBuild = true;

  makeFlags = [ "prefix=$(out)" ];

  meta = with lib; {
    homepage = "https://github.com/scottchiefbaker/dool";
    description = "Python3 compatible clone of dstat";
    license = licenses.gpl2;
    platforms = platforms.linux;
    changelog = "https://github.com/scottchiefbaker/dool/releases/tag/v${version}";
  };
}
