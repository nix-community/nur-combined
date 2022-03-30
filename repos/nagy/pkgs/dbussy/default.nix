{ lib, fetchFromGitHub, buildPythonPackage, dbus }:

buildPythonPackage rec {
  pname = "dbussy";
  version = "unstable-2022-01-28";

  src = fetchFromGitHub {
    owner = "Ldo";
    repo = pname;
    rev = "60d3c155d07ce11bdf89a201ae0026525ac65aca";
    sha256 = "0grffr3xpnqhsbfjsb95zp66dkgg1b0qyhr0n6y5ign45ngyxf6g";
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
