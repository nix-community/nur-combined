{
  lib,
  pkgs,
  config,
  vacuModules,
  ...
}:
{
  imports = [ vacuModules.vacuvmGuest ];

  vacu.systemKind = "server";

  services.openssh.enable = true;

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  users.users.agent = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = lib.attrValues config.vacu.ssh.authorizedKeys;
  };

  vacuvmGuest.ipv6Gateway = "2602:fce8:106:10::1";

  vacu.packages = {
    # upstream wrapper exports alsa-lib in LD_LIBRARY_PATH (for voice mode), which leaks into every tool shell
    claude-code.enable = true;
    claude-code.package = pkgs.claude-code.overrideAttrs (old: {
      postFixup = (old.postFixup or "") + ''
        sed -i '/LD_LIBRARY_PATH/d' $out/bin/claude
      '';
    });
    codex.enable = true;
  };

  vacu.git.enable = true;
}
