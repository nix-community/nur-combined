{ pkgs }: {
  pkgs = {
    riscVivid = pkgs.callPackage ./pkgs/riscVivid { };
    systemd-sops-creds = pkgs.callPackage ./pkgs/systemd-sops-creds.nix { };
  };
}
