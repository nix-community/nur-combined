{ lib, stdenv, fetchurl, python2Packages, libXScrnSaver, makeWrapper }:

python2Packages.buildPythonApplication rec {
  pname = "taskcoach";
  version = "1.4.6";

  src = fetchurl {
    url = "mirror://sourceforge/taskcoach/taskcoach/Release-${version}/TaskCoach-${version}.tar.gz";
    hash = "sha256-LvR/vGUWX43hClGdBxda5uwibFkGyMJWlEisE2NJX5g=";
  };

  propagatedBuildInputs = with python2Packages; [
    (twisted.overrideAttrs (old: {
      version = "20.3.0";
      src = fetchPypi {
        pname = "Twisted";
        version = "20.3.0";
        extension = "tar.bz2";
        sha256 = "040yzha6cyshnn6ljgk2birgh6mh2cnra48xp5ina5vfsnsmab6p";
      };
    }))
    wxPython
  ];

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
    broken = true;
  };
}
