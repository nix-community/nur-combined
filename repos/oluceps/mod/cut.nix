{
  flake.modules.nixos.cut =
    {
      ...
    }:
    {
      system = {
        copySystemConfiguration = false;
        nixos-init.enable = true;

        disableInstallerTools = true;
        tools.nixos-rebuild.enable = false;
      };
      boot = {
        enableContainers = false;
        initrd.systemd.enable = true;
        tmp.useTmpfs = true;
      };

      services = {
        journald.settings.Journal = {
          # 1G was rotating out the kernel OOM reports before they could be
          # read; keep enough history to post-mortem an OOM storm.
          SystemMaxUse = "4G";
        };

        #  = ''
        #   SystemMaxUse=1G
        # '';
        dbus.implementation = "broker";
      };
      programs = {
        less.lessopen = null;
        command-not-found.enable = false;
      };
      documentation = {
        info.enable = false;
        nixos.enable = false;
        man.man-db.enable = true;
      };

      system.etc.overlay = {
        enable = true;
        mutable = false;
      };
      # users.subIdRanges.strictOverlapCheck = true;
      # users.subIdRanges.static = true;
    };
}
