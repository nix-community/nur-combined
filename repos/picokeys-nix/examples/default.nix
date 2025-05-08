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
  pico-openpgp-eddsa = picopkgs.pico-openpgp.override {
    picoBoard = "waveshare_rp2350_one";
    vidPid = "Yubikey5";
    eddsaSupport = true;
  };
  pico-fido-eddsa = picopkgs.pico-fido.override {
    picoBoard = "waveshare_rp2350_one";
    vidPid = "Yubikey5";
    eddsaSupport = true;
  };
  pico-hsm-eddsa = picopkgs.pico-hsm.override {
    picoBoard = "waveshare_rp2350_one";
    vidPid = "Yubikey5";
    eddsaSupport = true;
  };
  pico-nuke = picopkgs.pico-nuke.override {
    picoBoard = "waveshare_rp2350_one";
  };
  # sign binary with own private key
  pico-openpgp-signed = picopkgs.pico-openpgp.override {
    picoBoard = "waveshare_rp2350_one";
    usbVid = "0xFEFF";
    usbPid = "0xFCFD";
    secureBootKey = "${./path/key.pem}";
    generateOtpFile = true; # gen otp.json in result/
  };
  pico-fido-signed = picopkgs.pico-fido.override {
    picoBoard = "waveshare_rp2350_one";
    usbVid = "0xFEFF";
    usbPid = "0xFCFD";
    secureBootKey = "${./path/key.pem}";
    generateOtpFile = true;
  };
  pico-hsm-signed = picopkgs.pico-hsm.override {
    picoBoard = "waveshare_rp2350_one";
    usbVid = "0xFEFF";
    usbPid = "0xFCFD";
    secureBootKey = "${./path/key.pem}";
    generateOtpFile = true;
  };
  pico-nuke-signed = picopkgs.pico-nuke.override {
    picoBoard = "waveshare_rp2350_one";
    secureBootKey = "${./path/key.pem}";
    generateOtpFile = true;
  };
}
