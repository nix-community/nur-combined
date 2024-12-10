{ config, pkgs, ... }:

{
  imports = [
    ./fs.nix
    ./net
    ./services
  ];

  # for administering services
  sane.programs.clightning-sane.enableFor.user.colin = true;
  # sane.programs.freshrss.enableFor.user.colin = true;
  # sane.programs.signaldctl.enableFor.user.colin = true;
  # sane.programs.matrix-synapse.enableFor.user.colin = true;

  sane.roles.build-machine.enable = true;
  sane.programs.sane-deadlines.config.showOnLogin = false;  # ~/knowledge doesn't always exist
  sane.programs.consoleUtils.suggestedPrograms = [
    "consoleMediaUtils"  # notably, for go2tv / casting
    "pcConsoleUtils"
    "sane-scripts.stop-all-servo"
  ];
  sane.services.dyn-dns.enable = true;
  sane.nixcache.remote-builders.desko = false;
  sane.nixcache.remote-builders.servo = false;
  sane.services.rsync-net.enable = true;

  # automatically log in at the virtual consoles.
  # using root here makes sure we always have an escape hatch.
  # XXX(2024-07-27): this is incompatible if using s6, which needs to auto-login as `colin` to start its user services.
  services.getty.autologinUser = "root";

  sane.image.extraBootFiles = [ pkgs.bootpart-uefi-x86_64 ];

  # both transmission and ipfs try to set different net defaults.
  # we just use the most aggressive of the two here:
  boot.kernel.sysctl = {
    "net.core.rmem_max" = 4194304;  # 4MB
  };
}

