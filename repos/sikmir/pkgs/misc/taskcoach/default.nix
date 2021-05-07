{ lib, stdenv, fetchurl, python2Packages, libXScrnSaver, makeWrapper }:

python2Packages.buildPythonApplication rec {
  pname = "taskcoach";
  version = "1.4.6";

  src = fetchurl {
    url = "mirror://sourceforge/taskcoach/taskcoach/Release-${version}/TaskCoach-${version}.tar.gz";
    sha256 = "162z95ii7b28jibc5j06b5n25v76b8bhg7ai1bhqspqncny7zx1f";
  };

  propagatedBuildInputs = with python2Packages; [ twisted wxPython ];

  doCheck = false;

  makeWrapperArgs = [
    "--prefix LD_PRELOAD : ${lib.makeLibraryPath [ libXScrnSaver ]}/libXss.so.1"
  ];

  meta = with lib; {
    description = "Your friendly task manager";
    homepage = "https://www.taskcoach.org/";
    license = licenses.gpl3Plus;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
}
