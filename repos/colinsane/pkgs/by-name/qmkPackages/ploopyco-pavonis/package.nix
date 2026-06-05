# see also:
# - PR to add trackpads to QMK: <https://github.com/qmk/qmk_firmware/pull/24964>
# - flokli's build: <https://github.com/flokli/keyboards/blob/wip-multitouch-experiment/keyboards/dilemma/default.nix>
#
# TODO: flash with: `QMK_HOME=${qmk_firmware_src} ${pkgs.qmk}/bin/qmk flash ${firmware}/$KEYBOARD.uf2`
{
  fetchFromGitHub,
  mkQmkFirmware,
}:
mkQmkFirmware {
  keyboard = "ploopyco/pavonis";
  keymap = "default";
  version = "0-unstable-2024-12-03";
  src = fetchFromGitHub {
    owner = "ploopyco";
    repo = "qmk_firmware";
    rev = "f18a37a8f0cbf328bb84f7abea10e522efda8842";
    hash = "sha256-CmJYTdSXAZDqszktnLdh4FkSfUdwvyXfV1vEVHB4irw=";
    fetchSubmodules = true;
  };
  meta = {
    homepage = "https://github.com/ploopyco/qmk_firmware/blob/multitouch_experiment/keyboards/ploopyco/pavonis/readme.md";
  };
}
