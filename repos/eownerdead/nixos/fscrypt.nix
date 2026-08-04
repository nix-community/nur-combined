{
  pkgs,
  lib,
  config,
  ...
}:
let
  fscryptAuth = pkgs.writeShellApplication {
    name = "fscrypt-auth";
    runtimeInputs = [
      pkgs.fscrypt-experimental
      config.system.path
    ];
    text = ''
      # set -x
      DIR="/nix/persist/home/$PAM_USER"
      fscrypt status "$DIR" | grep -q "Unlocked: Yes" && exit 0
      fscrypt unlock --user="$PAM_USER" --quiet "$DIR"
      chown "$PAM_USER:users" -R "/home/$PAM_USER"
      systemctl start --all "home-$PAM_USER-*.mount" || exit 0
      systemctl start "home-manager-$PAM_USER.service" || exit 0
    '';
  };

  fscryptUnlock = {
    enable = true;
    order = 11801;
    control = "sufficient";
    modulePath = "${config.security.pam.package}/lib/security/pam_exec.so";
    args = [
      # "debug"
      "expose_authtok"
      "${fscryptAuth}/bin/fscrypt-auth"
    ];
  };
in
{
  options.eownerdead.fscrypt = lib.mkEnableOption "Enable fscrypt";

  config = lib.mkIf config.eownerdead.fscrypt {
    security.pam.services = lib.genAttrs [ "login" ] (_: {
      rules.auth.fscrypt-unlock = fscryptUnlock;
    });
  };
}
