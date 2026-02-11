{ pkgs }: {
  pkgs = {
    riscVivid = pkgs.callPackage ./pkgs/riscVivid { };
    systemd-sops-creds = pkgs.callPackage ./pkgs/systemd-sops-creds.nix { };
    filebrowser-quantum = pkgs.callPackage ./pkgs/filebrowser-quantum.nix { };
    beszel-provisioner = pkgs.callPackage ./pkgs/beszel-provisioner.nix { };
    carddav-immich-bday-sync = pkgs.callPackage ./pkgs/carddav-immich-bday-sync { };
  };
}
