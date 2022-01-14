{ pkgs, lib, config, ... }:
let
  inherit (lib)
    fileContents
    mkOption
  ;
in {
  options.my.secrets = let inherit (lib) types; in mkOption {
    type = types.attrs;
  };

  config.my.secrets = {
    matrix-registration-shared-secret = fileContents ./matrix-registration-shared-secret.secret;
    shadow-hashed-password-alarsyo = fileContents ./shadow-hashed-password-alarsyo.secret;
    shadow-hashed-password-root = fileContents ./shadow-hashed-password-root.secret;
    miniflux-admin-credentials = fileContents ./miniflux-admin-credentials.secret;
    transmission-password = fileContents ./transmission.secret;
    nextcloud-admin-pass = ./nextcloud-admin-pass.secret;
    nextcloud-admin-user = fileContents ./nextcloud-admin-user.secret;
    lohr-shared-secret = fileContents ./lohr-shared-secret.secret;
    gandiKey = fileContents ./gandi-api-key.secret;

    borg-backup = import ./borg-backup { inherit lib; };
    paperless = import ./paperless { inherit lib; };
    restic-backup = import ./restic-backup { inherit lib; };

    matrixEmailConfig = import ./matrix-email-config.nix;
  };
}
