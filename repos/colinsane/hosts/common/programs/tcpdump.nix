{ pkgs, ... }: {
  sane.programs.tcpdump = {
    packageUnwrapped = pkgs.tcpdump.override {
      # enable packet capture for more protocols.
      # TODO: remove after <https://github.com/NixOS/nixpkgs/pull/429225>
      libpcap = pkgs.libpcap.overrideAttrs (upstream: {
        buildInputs = (upstream.buildInputs or []) ++ [
          pkgs.bluez
          pkgs.dbus
          pkgs.rdma-core
        ];
      });
    };

    sandbox.net = "all";
    sandbox.autodetectCliPaths = "existingFileOrParent";
    sandbox.capabilities = [ "net_admin" "net_raw" ];
    sandbox.tryKeepUsers = true;
  };
}
