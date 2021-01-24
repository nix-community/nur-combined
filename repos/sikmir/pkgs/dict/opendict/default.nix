{ lib, fetchFromGitHub, python2Packages, gettext, sources }:

python2Packages.buildPythonApplication rec {
  pname = "opendict";
  version = "0.6.8";

  src = fetchFromGitHub {
    owner = "nerijus";
    repo = "opendict";
    rev = version;
    sha256 = "0jgamfrvadbbj08yracx22j4350l3j7bgvw3w9yb6in2hh0wflbf";
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
    platforms = platforms.unix;
  };
}
