{ config, pkgs, lib, flake, ... }:
let
  readOnlySharedStore = import ../shared/read-only-store.nix;
  tailscaleKey = import ../shared/tailscale-identity-key.nix;
  journaldShare =
    import ../common/journald.nix { inherit (config.networking) hostName; };
in {

  networking = {
    hostName = "aipom";
    hostId = "0f5cb1b8";
  };

  microvm = {
    vcpu = 1;
    mem = 1024;
    hypervisor = "qemu";
    shares = [ readOnlySharedStore journaldShare ];
    # TODO: Rethink how this is done, we need to pass the guest key as only a guest key
    # shares = [ readOnlySharedStore tailscaleKey journaldShare ];
    interfaces = [{
      type = "tap";
      id = "vm-${config.networking.hostName}-01";
      mac = "00:00:00:00:00:01";
    }];
    writableStoreOverlay = null;
  };

  imports = [
    ../common/machine-id.nix
    ../../modules/microvm/guest
    ../../modules/ombi
    ../../modules/time
    ../../modules/timesyncd
  ];

  system.stateVersion = "22.11";
}
