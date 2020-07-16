{ lib
, fetchurl
, buildPythonPackage
, distutils_extra
, intltool
}:
let 
  pyModuleDeps = [
    distutils_extra
  ];
in
buildPythonPackage {

  pname = "gufw";
  version = "19.0.0";

  src = fetchurl {
    url = "https://launchpadlibrarian.net/430163942/gui-ufw-19.10.0.tar.gz";
    sha256 = "1fjw4lbcg7wwn30i2sbnzp9m791inmyq5fczr3kmgr32ggpmbh8q";
  };

  patches = [ ./fix-bash-error.patch ];

  postPatch = ''
    substituteInPlace bin/gufw \
      --replace "#!/bin/sh" "#!/bin/bash"
    patchShebangs bin/gufw
  '';
  
  nativeBuildInputs = [ intltool ];
  buildInputs = pyModuleDeps;
  propagatedBuildInputs = pyModuleDeps;

  doCheck = false;
  
  meta = with lib; {
    description = "Feature complete cross-platform Wii Remote access library";
    license = licenses.gpl3;
    homepage = "https://github.com/wiiuse/wiiuse";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = with platforms; linux;
  };
}
