{
  writeTextFile,
  lib,
  ...
}: let
  constants = import ../../helpers/constants.nix;
in
  writeTextFile rec {
    name = "00000-howto";
    text = ''
      This NUR has a binary cache. Use the following settings to access it:

      nix.settings.substituters = [ "${constants.url}" ];
      nix.settings.trusted-public-keys = [ "${constants.publicKey}" ];

      Or, use variables from this repository in case I change them:

      nix.settings.substituters = [ nur.repos.xddxdd._meta.url ];
      nix.settings.trusted-public-keys = [ nur.repos.xddxdd._meta.publicKey ];
    '';

    derivationArgs.passthru = constants;

    meta = {
      description = text;
      homepage = "https://github.com/xddxdd/nur-packages";
      license = lib.licenses.unlicense;
    };
  }
