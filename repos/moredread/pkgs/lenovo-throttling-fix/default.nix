{ stdenv, fetchFromGitHub, python3Packages, python3 }:

python3Packages.buildPythonApplication rec {
  name = "lenovo-throttling-fix-${version}";
  version = "0.3";

  src = fetchFromGitHub {
    owner = "erpalma";
    repo = "lenovo-throttling-fix";
    rev = "v${version}";
    sha256 = "1n7gzkim0qwlb95743m06ivc6zfd7n5k1r324xagqlzcczq47gps";
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
