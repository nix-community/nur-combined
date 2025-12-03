# everything to interact with my apex flex, pcsc stuff, fido2 stuff, etc
{
  pkgs,
  lib,
  config,
  ...
}:
let
  # to match package used in config.services.pcscd, unfortunately not exposed like usual
  pcsclite-pkg = if config.security.polkit.enable then pkgs.pcscliteWithPolkit else pkgs.pcsclite;
in
{
  # apparently this is already enabled??
  # nixpkgs.overlays = [ ( final: prev: {
  #   libfido2 = prev.libfido2.override { withPcsclite = true; };
  # } ) ];
  vacu.packages = lib.mkMerge [
    ''
      libfido2
      pcsc-tools
      scmccid
      opensc
      pcsclite
    ''
    { pcsclite.package = pcsclite-pkg; }
  ];

  services.pcscd.enable = true;
  # conflicts with pcscd, see https://stackoverflow.com/questions/55144458/unable-to-claim-usb-interface-device-or-resource-busy-stuck
  boot.blacklistedKernelModules = [
    "pn533_usb"
    "pn533"
    "nfc"
  ];

  # bunch of stuff from https://wiki.nixos.org/wiki/Web_eID

  # Tell p11-kit to load/proxy opensc-pkcs11.so, providing all available slots
  # (PIN1 for authentication/decryption, PIN2 for signing).
  # environment.etc."pkcs11/modules/opensc-pkcs11".text = ''
  #   module: ${pkgs.opensc}/lib/opensc-pkcs11.so
  # '';

  # environment.etc."opensc.conf".text = ''
  #   app default {
  #     reader_driver pcsc {
  #       enable_pinpad = false;
  #     }
  #   }
  # '';

  environment.systemPackages = [
    # Wrapper script to tell to Chrome/Chromium to use p11-kit-proxy to load
    # security devices, so they can be used for TLS client auth.
    # Each user needs to run this themselves, it does not work on a system level
    # due to a bug in Chromium:
    #
    # https://bugs.chromium.org/p/chromium/issues/detail?id=16387
    (pkgs.writeShellScriptBin "setup-browser-eid" ''
      NSSDB="''${HOME}/.pki/nssdb"
      mkdir -p ''${NSSDB}

      ${pkgs.nssTools}/bin/modutil -force -dbdir sql:$NSSDB -add p11-kit-proxy \
        -libfile ${pkgs.p11-kit}/lib/p11-kit-proxy.so
    '')
  ];

  # programs.firefox.enable = true;
  # programs.firefox.policies.SecurityDevices.p11-kit-proxy = "${pkgs.p11-kit}/lib/p11-kit-proxy.so";

  # trying CTAP-bridge
  services.udev.extraRules = ''
    KERNEL=="hidg[0-9]", SUBSYSTEM=="hidg", SYMLINK+="ctaphid", MODE="0666", TAG+="uaccess"
    KERNEL=="ccidg[0-9]", SUBSYSTEM=="ccidg", SYMLINK+="ccidsc", MODE="0666", TAG+="uaccess"
  '';
}
