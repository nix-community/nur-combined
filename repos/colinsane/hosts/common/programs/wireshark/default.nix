# use like: `sudo -E wireshark`  (`-E` to preserve the wayland environment)
{ pkgs, ... }:
{
  sane.programs.wireshark = {
    # ship *just* wireshark, else it calls out to helpers from the same package via PATH
    # which causes sandboxing errors (it won't sandbox recursively).
    packageUnwrapped = pkgs.linkIntoOwnPackage pkgs.wireshark [
      "bin/wireshark"
      "share"
    ] {};

    sandbox.autodetectCliPaths = "existingFile";  #< for loading pcap files on CLI
    sandbox.whitelistWayland = true;
    sandbox.net = "all";
    sandbox.capabilities = [
      "dac_override"  #< this wasn't needed with landlock; only bunpen
      "net_admin"
      "net_raw"
    ];
    sandbox.tryKeepUsers = true;
    # sandbox.extraPaths = [
    #   "/proc/net"  #< only needed if using landlock
    # ];

    fs.".config/wireshark".dir = {};
    buildCost = 2;
  };
}
