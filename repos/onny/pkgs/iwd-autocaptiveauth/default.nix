{ stdenv, python, fetchgit, iwd }:

with python.pkgs;
stdenv.mkDerivation rec {
  pname = "iwd-autocaptiveauth";
  version = "0.5";
  src = fetchgit {
    url = "https://git.project-insanity.org/onny/py-iwd-autocaptiveauth.git";
    rev = "e60a9f6210b6f0827ba01c31e653672f049cd3ce";
    sha256 = "0xarb5pd45qwxaz2ilv88i9byysvzd95ij8356nr2yj383xngvsg";
  };


  pythonPath = [ 
    dbus-python
    pygobject3
  ];

  nativeBuildInputs = [
    wrapPython
  ];

  dontBuild = true;

  installPhase = "
    cp -av profiles $out/
    install -D iwd-autocaptiveauth.py $out/bin/iwd-autocaptiveauth
  ";

  postFixup = "wrapPythonPrograms";

  meta = with stdenv.lib; {
    description = "iwd automatic authentication to captive portals";
    homepage = "https://git.project-insanity.org/onny/py-iwd-autocaptiveauth";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
