{ stdenv, python3, fetchgit, iwd }:

with python3.pkgs;
stdenv.mkDerivation rec {
  pname = "iwd-autocaptiveauth";
  version = "0.8.1";
  src = fetchgit {
    url = "https://git.project-insanity.org/onny/py-iwd-autocaptiveauth.git";
    rev = "ee9a8f671bbbba1f8bb2e7bab51af430d980d130";
    sha256 = "05xjaci0cwq65iv56mvhapv0z2683wkdwas0hhs6mxhmvnpyzm3m";
  };

  buildInputs = [ 
    python3
  ];

  pythonPath = [ 
    dbus-python
    pygobject3
  ];

  nativeBuildInputs = [
    wrapPython
  ];

  dontBuild = true;

  installPhase = "
    mkdir -p $out/profiles
    cp -rav profiles/* $out/profiles/
    install -vD iwd-autocaptiveauth.py $out/bin/iwd-autocaptiveauth
  ";

  postPatch = "
    substituteInPlace iwd-autocaptiveauth.py --replace 'hyperpotamus' '/bin/hyperpotamus'
  ";

  postFixup = "
    wrapPythonPrograms
  ";

  meta = with stdenv.lib; {
    description = "iwd automatic authentication to captive portals";
    homepage = "https://git.project-insanity.org/onny/py-iwd-autocaptiveauth";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
