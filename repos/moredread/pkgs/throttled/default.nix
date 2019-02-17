{ stdenv, fetchFromGitHub, python3Packages, python3 }:

python3Packages.buildPythonApplication rec {
  name = "lenovo-throttling-fix-${version}";
  version = "52d83c41bb67af180cf511e2ad93ceec8e2c9c09";

  src = fetchFromGitHub {
    owner = "erpalma";
    repo = "throttled";
    rev = "${version}";
    sha256 = "1dp0zi5xxi1h9p1p6p2ki67scj1by4kawy4lvkg7s4gzkb2y7r0c";
  };

  propagatedBuildInputs = with python3Packages; [
    configparser
    dbus-python
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
