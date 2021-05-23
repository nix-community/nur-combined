{ lib
, buildPythonApplication
, fetchFromGitHub
, dbus-python
, pygobject3
, python-prctl
, python
}:

buildPythonApplication rec {
  pname = "bluetooth-autoconnect";
  version = "1.3";
  format = "other";

  src = fetchFromGitHub {
    owner = "jrouleau";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-qfU7fNPNRQxIxxfKZkGAM6Wd3NMuNI+8DqeUW+LYRUw=";
  };

  propagatedBuildInputs = [ dbus-python pygobject3 python-prctl ];

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/bin"
    cp bluetooth-autoconnect "$out/bin"
    runHook postInstall
  '';

  preFixup = ''
    substituteInPlace $out/bin/bluetooth-autoconnect \
      --replace '#!/usr/bin/env -S python3 -u' '#!${python}/bin/python'
  '';

  meta = with lib; {
    description = "A linux command line tool to automatically connect to all paired and trusted bluetooth devices";
    homepage = "https://github.com/jrouleau/bluetooth-autoconnect";
    license = licenses.mit;
    maintainers = with maintainers; [ kira-bruneau ];
    platforms = platforms.linux;
  };
}
