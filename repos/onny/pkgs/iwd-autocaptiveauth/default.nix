{ stdenv, python, fetchgit, makeWrapper, iwd, python3Packages }:

stdenv.mkDerivation rec {
  pname = "iwd-autocaptiveauth";
  version = "0.4";
  src = fetchgit {
    url = "https://git.project-insanity.org/onny/py-iwd-autocaptiveauth.git";
    rev = "45523620596b4a28e6d269cead690031774d23cf";
    sha256 = "02w7zgglk8siyybji3gwv43fy2s00vqd2vzkw1hx07qiq842vjy4";
  };

  buildInputs  = [ makeWrapper ];

  propagatedBuildInputs = with python3Packages; [
    dbus-python
    pygobject3
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp -av iwd-autocaptiveauth.py profiles $out/
    chmod 555 $out/iwd-autocaptiveauth.py
    makeWrapper $out/iwd-autocaptiveauth.py $out/bin/iwd-autocaptiveauth
  '';

  meta = with stdenv.lib; {
    description = "iwd automatic authentication to captive portals";
    homepage = "https://git.project-insanity.org/onny/py-iwd-autocaptiveauth";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
