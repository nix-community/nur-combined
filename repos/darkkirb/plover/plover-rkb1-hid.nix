{
  callPackage,
  buildPythonPackage,
  fetchFromGitea,
  lib,
  pythonOlder,
  hid,
  bitstring,
}: let
  plover = callPackage ./plover {};
  source = builtins.fromJSON (builtins.readFile ./plover-rkb1-hid.json);
in
  buildPythonPackage rec {
    pname = "plover_machine_hid";
    version = source.date;
    src = fetchFromGitea {
      domain = "git.chir.rs";
      owner = "darkkirb";
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
    passthru.updateScript = [../scripts/update-git.sh "https://git.chir.rs/darkkirb/plover-machine-hid" "plover/plover-rkb1-hid.json"];
  }
