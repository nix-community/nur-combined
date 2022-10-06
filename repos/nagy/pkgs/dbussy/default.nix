{ lib, fetchFromGitHub, buildPythonPackage, dbus }:

buildPythonPackage rec {
  pname = "dbussy";
  version = "unstable-2022-09-03";

  src = fetchFromGitHub {
    owner = "Ldo";
    repo = pname;
    rev = "71616a370d3f59ef1681d26f5df77c1545d5bc04";
    sha256 = "sha256-WlyiW1LlVpYsIHOR/SUhA5+vGMp/RZmPK7T63iycyvc=";
  };

  pythonImportsCheck = [ "dbussy" ];

  prePatch = ''
    substituteInPlace dbussy.py \
        --replace libdbus-1.so.3 ${dbus.lib}/lib/libdbus-1.so.3
  '';

  meta = with lib; {
    description = "Python binding for D-Bus using asyncio";
    homepage = "https://github.com/ldo/dbussy";
    license = licenses.lgpl21;
    platforms = platforms.linux;
  };
}
