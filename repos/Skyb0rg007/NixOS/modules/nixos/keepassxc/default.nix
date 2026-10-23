{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.programs.keepassxc;

  # Mirrors share/linux/org.keepassxc.KeePassXC.policy.in from upstream.
  # Shipped separately so that AppImage installs, which cannot register polkit
  # actions themselves, can still use Quick Unlock. The Flatpak cannot use it:
  # Flatpak's seccomp filter blocks the kernel keyring syscalls it relies on.
  policy = pkgs.writeTextFile {
    name = "keepassxc-polkit-policy";
    destination = "/share/polkit-1/actions/org.keepassxc.KeePassXC.policy";
    text = ''
      <?xml version="1.0" encoding="utf-8"?>
      <!DOCTYPE policyconfig PUBLIC
       "-//freedesktop//DTD PolicyKit Policy Configuration 1.0//EN"
       "http://www.freedesktop.org/standards/PolicyKit/1.0/policyconfig.dtd">
      <policyconfig>
        <vendor>KeePassXC Developers</vendor>
        <vendor_url></vendor_url>
        <icon_name>keepassxc</icon_name>

        <action id="org.keepassxc.KeePassXC.unlockDatabase">
          <description>Quick Unlock for a KeePassXC Database</description>
          <message>Authentication is required to unlock a KeePassXC Database</message>
          <defaults>
            <allow_inactive>no</allow_inactive>
            <allow_active>auth_self</allow_active>
          </defaults>
        </action>
      </policyconfig>
    '';
  };
in
{
  options.programs.keepassxc = {
    enable = lib.mkEnableOption "KeePassXC system integration";

    package = lib.mkPackageOption pkgs "keepassxc" {
      nullable = true;
      default = null;
      example = "keepassxc";
      extraDescription = ''
        Leave as `null` when KeePassXC is installed some other way, such as
        the AppImage or a per-user profile; the system-wide integration below
        is installed regardless.
      '';
    };

    quickUnlock = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          Whether to register the `org.keepassxc.KeePassXC.unlockDatabase`
          polkit action used by KeePassXC (2.8.0 and later) for Quick Unlock
          on Linux. The user must re-authenticate as themselves through their
          session's polkit agent to unlock a database that was previously
          opened with full credentials.

          This does not help the Flatpak build, whose seccomp filter blocks
          the kernel keyring syscalls Quick Unlock needs.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages =
      lib.optional (cfg.package != null) cfg.package
      # Low priority so a package that ships its own copy of the policy wins
      # the collision in system-path.
      ++ lib.optional cfg.quickUnlock.enable (lib.lowPrio policy);

    security.polkit.enable = lib.mkIf cfg.quickUnlock.enable true;

    warnings =
      lib.optional
        (
          cfg.quickUnlock.enable
          && cfg.package != null
          && lib.versionOlder (lib.getVersion cfg.package) "2.8.0"
        )
        "programs.keepassxc: Quick Unlock via polkit requires KeePassXC 2.8.0 or later, but programs.keepassxc.package is ${lib.getVersion cfg.package}.";
  };
}
