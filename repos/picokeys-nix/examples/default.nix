{
  pkgs ? import <nixpkgs> { },
}:
let
  picopkgs =
    import (builtins.fetchTarball "https://github.com/ViZiD/picokeys-nix/archive/master.tar.gz")
      {
        inherit pkgs;
      };
in
{
  # replace picoBoard with your board
  # set vid and pid or vidPid
  pico-openpgp = picopkgs.pico-openpgp.override {
    picoBoard = "waveshare_rp2350_one";
    usbVid = "0xFEFF";
    usbPid = "0xFCFD";
  };
  pico-fido = picopkgs.pico-fido.override {
    picoBoard = "waveshare_rp2350_one";
    usbVid = "0xFEFF";
    usbPid = "0xFCFD";
  };
  pico-hsm = picopkgs.pico-hsm.override {
    picoBoard = "waveshare_rp2350_one";
    usbVid = "0xFEFF";
    usbPid = "0xFCFD";
  };
  # if you need eddsa support
  pico-openpgp-eddsa = picopkgs.pico-openpgp-eddsa.override {
    picoBoard = "waveshare_rp2350_one";
    vidPid = "Yubikey5";
  };
  pico-fido-eddsa = picopkgs.pico-fido-eddsa.override {
    picoBoard = "waveshare_rp2350_one";
    vidPid = "Yubikey5";
  };
  pico-hsm-eddsa = picopkgs.pico-hsm-eddsa.override {
    picoBoard = "waveshare_rp2350_one";
    vidPid = "Yubikey5";
  };
  pico-nuke = picopkgs.pico-nuke.override {
    picoBoard = "waveshare_rp2350_one";
  };
}
