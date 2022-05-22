{ lib, fetchFromGitHub, python2Packages, gettext }:

python2Packages.buildPythonApplication rec {
  pname = "opendict";
  version = "0.6.8";

  src = fetchFromGitHub {
    owner = "nerijus";
    repo = pname;
    rev = version;
    hash = "sha256-blHHAYTCRrN84oPvt44cFJRBpBCdqewRkGs1tbOr6kk=";
  };

  patches = [ ./0001-fix-makefile.patch ];

  nativeBuildInputs = [ gettext ];
  propagatedBuildInputs = with python2Packages; [ wxPython30 ];

  dontUseSetuptoolsBuild = true;
  dontUseSetuptoolsCheck = true;
  dontUsePipInstall = true;

  makeFlags = [ "DESTDIR=$(out)" ];
  makeWrapperArgs = [ "--prefix PYTHONPATH : $out/share/opendict" ];

  meta = with lib; {
    description = "Free multiplatform dictionary";
    homepage = "http://opendict.sf.net/";
    license = licenses.gpl2Plus;
    maintainers = [ maintainers.sikmir ];
    skip.ci = true;
  };
}
