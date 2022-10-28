{
  callPackage,
  buildPythonPackage,
  fetchFromGitHub,
  lib,
  pythonOlder,
  hid,
  bitstring,
}: let
  plover = callPackage ./plover {};
  source = builtins.fromJSON (builtins.readFile ./plover-machine-hid.json);
in
  buildPythonPackage rec {
    pname = "plover_machine_hid";
    version = source.date;
    src = fetchFromGitHub {
      owner = "dnaq";
      repo = "plover-machine-hid";
      inherit (source) rev sha256;
    };

    doCheck = false;

    disabled = pythonOlder "3.6";
    propagatedBuildInputs = [plover hid bitstring];

    meta = with lib; {
      description = "POC Plover plugin and firmware for the Plover HID protocol";
      license = licenses.mit;
    };
    passthru.updateScript = [../scripts/update-git.sh "https://github.com/dnaq/plover-machine-hid" "plover/plover-machine-hid.json"];
  }
