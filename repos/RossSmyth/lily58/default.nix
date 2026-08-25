{
  lib,
  fetchFromGitHub,
  buildQmkFirmware,
  gcc-arm-embedded,
}:
let
  init = buildQmkFirmware {
    qmkFirmware = fetchFromGitHub {
      owner = "KeyboardHoarders";
      repo = "vial-qmk";
      rev = "0ee1c47feb5218db61dc71f066d94b272d451034";
      fetchSubmodules = true;
      hash = "sha256-/AlqkwuXvn4SFuzgdBiSg1noPkR5Ilq6iPFCwlFVsZw=";
    };

    split = true;

    keyboard = "lily58/rev1";
    keymap = "vialtrackpad";
  };

  needle = ''--keymap "$keymap" "$@"'';
in
init.overrideAttrs (old: {
  postPatch = ''
    patchShebangs --build "$QMK_FIRMWARE/util"
  '';

  buildPhase =
    lib.replaceString needle
      ''--keymap "$keymap" -e "CONVERT_TO=rp2040_ce" -e "SILENT=false" -e "VERBOSE=true" "$@"''
      old.buildPhase;
  env = old.env // {
    VERBOSE = true;
  };
  nativeBuildInputs = [
    gcc-arm-embedded
  ];
})
