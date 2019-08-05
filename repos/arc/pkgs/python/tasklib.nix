{ lib, pythonPackages, taskwarrior, writeShellScriptBin }:

with pythonPackages;

let

wsl_stub = writeShellScriptBin "wsl" ''
  true
'';

in buildPythonPackage rec {
  pname = "tasklib";
  version = "1.2.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0gr7b4h0qyp3waxbd48rk4s2b4yhd5zbdpcaf3icavgqhxzgnr1r";
  };

  propagatedBuildInputs = [
    six
    pytz
    tzlocal
  ];

  checkInputs = [
    taskwarrior
    wsl_stub
  ];
}
