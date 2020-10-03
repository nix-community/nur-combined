{ lib
, buildPythonApplication
, fetchFromGitHub
, dbus-python
, pygobject3
, python
}:

buildPythonApplication rec {
  pname = "bluetooth-autoconnect";
  version = "1.1";
  format = "other";

  src = fetchFromGitHub {
    owner = "jrouleau";
    repo = pname;
    rev = "v${version}";
    sha256 = "1d7y1afqhhkhpfw2b1bf5nm5ybkxql2kbp4091xwjhb9dcd9mcph";
  };

  propagatedBuildInputs = [ dbus-python pygobject3 ];

  installPhase = ''
    mkdir -p "$out/bin"
    cp bluetooth-autoconnect "$out/bin"
  '';

  preFixup = ''
    substituteInPlace $out/bin/bluetooth-autoconnect \
      --replace '#!/usr/bin/env -S python3 -u' '#!${python}/bin/python'
  '';

  meta = with lib; {
    description = "A linux command line tool to automatically connect to all paired and trusted bluetooth devices";
    homepage = "https://github.com/jrouleau/bluetooth-autoconnect";
    license = licenses.mit;
    maintainers = with maintainers; [ metadark ];
  };
}
