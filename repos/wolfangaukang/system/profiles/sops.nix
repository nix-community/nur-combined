# Sops setup for any host
{ inputs
, ...
}:

let
  inherit (inputs) self sops;

in
{
  imports = [
    sops.nixosModules.sops
  ];

  sops = {
    defaultSopsFile = "${self}/system/hosts/common/secrets.yml";
    age = {
      keyFile = "/persist/var/lib/sops-nix/keys.txt";
      # Using /persist feels hacky, but /etc gets mounted/linked
      # after sops-nix is executed on boot.
      sshKeyPaths = [ "/persist/etc/ssh/ssh_host_ed25519_key" ];
    };
  };
}
