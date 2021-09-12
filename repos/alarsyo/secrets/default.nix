{ pkgs, lib, config, ... }:
with lib;
{
  options.my.secrets = mkOption {
    type = types.attrs;
  };

  config.my.secrets = {
    matrix-registration-shared-secret = lib.fileContents ./matrix-registration-shared-secret.secret;
    shadow-hashed-password-alarsyo = lib.fileContents ./shadow-hashed-password-alarsyo.secret;
    shadow-hashed-password-root = lib.fileContents ./shadow-hashed-password-root.secret;
    miniflux-admin-credentials = lib.fileContents ./miniflux-admin-credentials.secret;
    transmission-password = lib.fileContents ./transmission.secret;
    nextcloud-admin-pass = lib.fileContents ./nextcloud-admin-pass.secret;
    nextcloud-admin-user = lib.fileContents ./nextcloud-admin-user.secret;
    lohr-shared-secret = lib.fileContents ./lohr-shared-secret.secret;
    gandiKey = lib.fileContents ./gandi-api-key.secret;

    borg-backup = import ./borg-backup { inherit lib; };
    restic-backup = import ./restic-backup { inherit lib; };

    matrixEmailConfig = import ./matrix-email-config.nix;

    prololo_password = lib.fileContents ./prololo-password.secret;
    prololo_room = lib.fileContents ./prololo-room.secret;
    prololo_github_secret = lib.fileContents ./prololo-github-secret.secret;
  };
}
