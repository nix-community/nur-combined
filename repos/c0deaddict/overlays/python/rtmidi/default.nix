{ lib
, buildPythonPackage
, fetchgit
, unittest2
, alsaLib
, isPy3k
}:

buildPythonPackage rec {
  pname = "rtmidi";
  version = "994d876ed1c929aab56832fb0888362a5d10c1fb";

  src = fetchgit {
    url = "git://github.com/patrickkidd/pyrtmidi.git";
    rev = "${version}";
    sha256 = "1gfspd54qdg301ynalwxmdc2x90g9xzh3lzpypkv7sqvx45gdfy5";
  };

  buildInputs = [ alsaLib ];

  # Broken on Python 3.7
  disabled = isPy3k;

  checkInputs = [ unittest2 ];

  checkPhase = ''
    ls tests
    python -m unittest
  '';

  meta = with lib; {
    homepage = "https://github.com/patrickkidd/pyrtmidi";
    description = "Realtime MIDI I/O for python";
    license = licenses.gpl;
    maintainers = with maintainers; [ c0deaddict ];
  };
}
