# docs: <https://wiki.nixos.org/wiki/Printing>
# to add a printer:
# 1. <http://localhost:631/admin/>
# 2. click "find new printers" and follow prompts
#   - prefer to use the "Generic IPP Everywhere Printer" driver
# alternatively, add/modify printers by running
# - `system-config-printer`
{ config, lib, ... }:
let
  cfg = config.sane.programs.cups;
in
{
  sane.programs.cups = {
    sandbox.method = null;  #< TODO: sandbox
    suggestedPrograms = [
      "system-config-printer"
    ];
  };
  sane.programs.system-config-printer.sandbox.method = null;  #< TODO: sandbox

  services.printing = lib.mkIf cfg.enabled {
    enable = true;
    startWhenNeeded = false;  #< a.k.a. socket activated?
    # webInterface = false;
    # logLevel = "debug";  # default: "info"
    # extraConfig = "<lines ... >";
    # drivers = [ <cups driver packages...> ]
  };
  # services.avahi = lib.mkIf cfg.enabled {
  #   # only needed for wireless printing
  #   enable = true;
  #   nssmdns4 = true;
  #   openFirewall = true;
  # };
}
