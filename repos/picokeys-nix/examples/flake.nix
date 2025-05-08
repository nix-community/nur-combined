{
  description = "Example flake for build Pico HSM/OpenPGP/Fido firmware";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    picokeys-nix.url = "github:ViZiD/picokeys-nix";
  };
  outputs =
    {
      self,
      picokeys-nix,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        picopkgs = picokeys-nix.packages.${system};
      in
      {
        packages = {
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
        };
      }
    );
}
