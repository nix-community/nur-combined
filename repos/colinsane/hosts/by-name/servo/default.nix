{ config, pkgs, ... }:

{
  imports = [
    ./fs.nix
    ./net.nix
    ./services
  ];

  # for administering services
  sane.programs.clightning-sane.enableFor.user.colin = true;
  # sane.programs.freshrss.enableFor.user.colin = true;
  # sane.programs.signaldctl.enableFor.user.colin = true;
  # sane.programs.matrix-synapse.enableFor.user.colin = true;

  sane.roles.build-machine.enable = true;
  sane.programs.zsh.config.showDeadlines = false;  # ~/knowledge doesn't always exist
  sane.programs.consoleUtils.suggestedPrograms = [
    "consoleMediaUtils"  # notably, for go2tv / casting
    "pcConsoleUtils"
    "sane-scripts.stop-all-servo"
  ];
  sane.services.dyn-dns.enable = true;
  sane.services.trust-dns.asSystemResolver = false;  # TODO: enable once it's all working well
  sane.services.wg-home.enable = true;
  sane.services.wg-home.visibleToWan = true;
  sane.services.wg-home.forwardToWan = true;
  sane.services.wg-home.routeThroughServo = false;
  sane.services.wg-home.ip = config.sane.hosts.by-name."servo".wg-home.ip;
  sane.ovpn.addrV4 = "172.23.174.114";
  # sane.ovpn.addrV6 = "fd00:0000:1337:cafe:1111:1111:8df3:14b0";
  sane.nixcache.remote-builders.desko = false;
  sane.nixcache.remote-builders.servo = false;
  # sane.services.duplicity.enable = true;  # TODO: re-enable after HW upgrade

  # automatically log in at the virtual consoles.
  # using root here makes sure we always have an escape hatch
  services.getty.autologinUser = "root";

  sane.image.extraBootFiles = [ pkgs.bootpart-uefi-x86_64 ];

  # both transmission and ipfs try to set different net defaults.
  # we just use the most aggressive of the two here:
  boot.kernel.sysctl = {
    "net.core.rmem_max" = 4194304;  # 4MB
  };
}

