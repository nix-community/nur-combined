{
  lib,
  fetchFromGitLab,
  buildPythonPackage,
  dbus,
}:

buildPythonPackage {
  pname = "dbussy";
  version = "1.3-unstable-2024-08-30";

  src = fetchFromGitLab {
    owner = "ldo";
    repo = "dbussy";
    rev = "35726d27fd0142ca13fb59e4e0a32e9d85b06659";
    hash = "sha256-aS8XvUirb50N8UHaedVP4It5SXhUq4m4Bo1fHTGWBgw=";
  };

  pythonImportsCheck = [ "dbussy" ];

  prePatch = ''
    substituteInPlace dbussy.py \
      --replace-fail libdbus-1.so.3 ${dbus.lib}/lib/libdbus-1.so.3
  '';

  meta = {
    description = "Python binding for D-Bus using asyncio";
    homepage = "https://gitlab.com/ldo/dbussy";
    license = lib.licenses.lgpl21;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ nagy ];
  };
}
