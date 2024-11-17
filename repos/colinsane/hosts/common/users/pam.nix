{ lib, pkgs, ... }:

let
  libcapForPam = pkgs.libcap;
  # optional debug configuration for pam.
  # enabling PAM_DEBUG for one module does not affect any other modules in the process space.
  # with this, messages produced by `D((...))` supposedly go to `/var/run/pam-debug.log`,
  # but in practice they just go to stderr (seems to be the failover in case the above can't be opened).
  # libcapForPam = pkgs.libcap.overrideAttrs (base: {
  #   postPatch = (base.postPatch or "") + ''
  #     substituteInPlace pam_cap/pam_cap.c \
  #       --replace '/* #define PAM_DEBUG */' '#define PAM_DEBUG'
  #   '';
  # });
in lib.mkIf false  #< XXX(2024-11-17): i haven't been using pam_cap, because namespace-based sandboxing (bubblewrap) loses capabilities
{
  # pam.d ordering (auth section only):
  # /etc/pam.d/login:
  #   auth optional pam_unix.so likeauth nullok # unix-early (order 11600)
  #   auth optional /nix/store/051v0pwqfy1z7ld6087y99fdrv12113n-pam_mount-2.20/lib/security/pam_mount.so disable_interactive # mount (order 12000)
  #   auth optional /nix/store/82zqzh7i88pxybcf48zapnz4v0jf19nm-gnome-keyring-42.1/lib/security/pam_gnome_keyring.so # gnome_keyring (order 12200)
  #   auth sufficient pam_unix.so likeauth nullok try_first_pass # unix (order 12800)
  #   auth required pam_deny.so # deny (order 13600)
  # /etc/pam.d/sshd: `auth required pam_deny.so # deny (order 12400)`
  # /etc/pam.d/su:
  #   auth sufficient pam_rootok.so # rootok (order 10200)
  #   auth required pam_faillock.so # faillock (order 10400)
  #   auth optional pam_unix.so likeauth # unix-early (order 11600)
  #   auth optional /nix/store/9adhmj7alv2wamnvkcv3746hwygrps52-pam_mount-2.20/lib/security/pam_mount.so disable_interactive # mount (order 12000)
  #   auth optional /nix/store/984ww6bccnlfvljy84d8y5dd7k9yd0h1-libcap-2.69-pam/lib/security/pam_cap.so keepcaps defer # pam_cap (order 12700)
  #   auth sufficient pam_unix.so likeauth try_first_pass # unix (order 12800)
  #   auth required pam_deny.so # deny (order 13600)
  # /etc/pam.d/sudo:
  #   auth optional pam_unix.so likeauth # unix-early (order 11600)
  #   auth optional /nix/store/051v0pwqfy1z7ld6087y99fdrv12113n-pam_mount-2.20/lib/security/pam_mount.so disable_interactive # mount (order 12000)
  #   auth sufficient pam_unix.so likeauth try_first_pass # unix (order 12800)
  #   auth required pam_deny.so # deny (order 13600)
  # /etc/pam.d/systemd-user:
  #   auth sufficient pam_unix.so likeauth try_first_pass # unix (order 11600)
  #   auth required pam_deny.so # deny (order 12400)

  # brief overview of PAM order/control:
  # - rules are executed sequentially
  # - a rule marked "optional": doesn't affect control flow.
  # - a rule marked "sufficient": on success, early-returns a success value and no further rules are executed.
  #   on failure, control flow is normal.
  # - a rule marked "required": on failure, early-returns a fail value and no further rules are executed.
  #   on success, control flow is normal.
  # hence, supplementary things like pam_mount, pam_cap, should be marked "optional" and occur before the first "sufficient" rule.
  #
  # pam_cap module args are in pam_cap/pam_cap.c:parse_args:
  # - debug
  # - config=<filename>
  # - keepcaps
  # - autoauth
  # - default=<string>
  # - defer
  #
  # about propagating capabilities to PAM consumers:
  # - `setuid` call typically drops all ambient capabilities.
  #   but setting keepcaps first will preserve the caps across a setuid call
  # - pam_cap bug, and fix: <https://bugzilla.kernel.org/show_bug.cgi?id=212945#c5>
  # - may need to use keepcaps + defer: <https://bugzilla.kernel.org/show_bug.cgi?id=214377#c3>

  security.pam.services.login.rules = {
    # keepcaps + defer WORKS
    auth.pam_cap = {
      order = 10100;  #< must be early, before "auth sufficient pam_unix.so"
      control = "optional";
      modulePath = "${libcapForPam.pam}/lib/security/pam_cap.so";
      args = [ "keepcaps" "defer" ];
      # args = [ "keepcaps" "defer" "debug" ];
    };
  };
  # security.pam.services.sshd.rules = {
  #   # 2024/01/28: sshd only supports caps in the I set, because of the keep-caps/setuid issue (above)
  #   auth.pam_cap = {
  #     order = 12300;
  #     control = "optional";
  #     modulePath = "${libcapForPam.pam}/lib/security/pam_cap.so";
  #     args = [ "keepcaps" "defer" "debug" ];  #< doesn't take effect
  #   };
  # };
  security.pam.services.su.rules = {
    # keepcaps + defer WORKS
    auth.pam_cap = {
      order = 10100;  #< must be early, before "auth sufficient pam_rootok.so"!
      control = "optional";
      modulePath = "${libcapForPam.pam}/lib/security/pam_cap.so";
      args = [ "keepcaps" "defer" ];
      # args = [ "keepcaps" "defer" "debug" ];
    };
  };
  # security.pam.services.sudo.rules = {
  #   # 2024/01/28: sudo only supports caps in the I set, because of the keep-caps/setuid issue (above)
  #   auth.pam_cap = {
  #     # order = 11500;
  #     order = 12700;
  #     control = "optional";
  #     modulePath = "${libcapForPam.pam}/lib/security/pam_cap.so";
  #     args = [ "keepcaps" "defer" "debug" ];  #< doesn't take effect
  #   };
  # };
  # security.pam.services.systemd-user.rules = {
  #   # 2024/01/28: systemd-user seems to override whatever pam_cap tries to set (?)
  #   auth.pam_cap = {
  #     order = 11500;
  #     control = "optional";
  #     modulePath = "${libcapForPam.pam}/lib/security/pam_cap.so";
  #     args = [ "keepcaps" "defer" "debug" ];  #< doesn't take effect
  #   };
  # };
}
