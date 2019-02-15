{ stdenv, fetchFromGitHub, python3Packages, python3 }:

python3Packages.buildPythonApplication rec {
  name = "lenovo-throttling-fix-${version}";
  version = "0.5";

  src = fetchFromGitHub {
    owner = "erpalma";
    repo = "throttled";
    rev = "v${version}";
    sha256 = "15jrigsx6n5a2ap2z0yk9niw0hzqlmd5vwb8b3g3vq8g70plfxfc";
  };

  propagatedBuildInputs = with python3Packages; [
    configparser
    dbus-python
    psutil
    pygobject3
  ];

  # No setup.py, so we skip the build phase
  buildPhase = "";

  installPhase = ''
    mkdir -p $out/bin $out/etc

    cp lenovo_fix.py $out/bin/lenovo_fix
    cp mmio.py $out/bin
    cp etc/lenovo_fix.conf $out/etc
  '';

  doCheck = false;
  doInstallCheck = false;

  meta = with stdenv.lib; {
    description = "Warning: WIP, package name might change. Script fixing temperature CPU throttling for some Lenovo and Dell laptops";
    platforms = platforms.linux;
    maintainers = [ maintainers.moredread ];
  };
}
