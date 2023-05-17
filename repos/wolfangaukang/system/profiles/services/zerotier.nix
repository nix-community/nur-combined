{ inputs
, hostname
, ...
}:

let
  inherit (inputs) self;
  system-lib = import "${self}/system/lib" { inherit inputs; };
  inherit (system-lib) obtainIPV4Address;

in {
  services = {
    zerotierone = {
      enable = true;
      joinNetworks = [ "a09acf02337dcfe5" ];
    };
    openssh.listenAddresses = [
      {
        addr = (obtainIPV4Address hostname "vestfirdir");
        port = 22;
      }
    ];
  };
}
