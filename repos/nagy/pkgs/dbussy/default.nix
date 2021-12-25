{ lib, fetchFromGitHub, python3Packages, dbus }:

python3Packages.buildPythonPackage rec {
  pname = "dbussy";
  version = "unstable-2021-11-07";

  src = fetchFromGitHub {
    owner = "Ldo";
    repo = "dbussy";
    rev = "a694e3b525e988dc5362f2278e2aacdf06b3a179";
    sha256 = "0if40gy9l9dx8583fs5pa99shzm4xywdhvxrbc527g0bdahcgf67";
  };

  pythonImportsCheck = [ "dbussy" ];

  propagatedBuildInputs = [ dbus ];

  prePatch = ''
    substituteInPlace dbussy.py \
        --replace libdbus-1.so.3 ${dbus.lib}/lib/libdbus-1.so.3
  '';

  meta = with lib; {
    license = licenses.lgpl21;
    platforms = platforms.linux;
  };
}
