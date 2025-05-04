{
  lib,
  writeShellApplication,
}:
writeShellApplication rec {
  name = "nixos-cleanup";
  derivationArgs.version = "1.0";
  text = ''
    nix-env -p /nix/var/nix/profiles/system --delete-generations +1 || true
    nix-env -p /root/.local/state/nix/profiles/home-manager --delete-generations +1 || true
    nix-env -p /home/lantian/.local/state/nix/profiles/home-manager --delete-generations +1 || true
    nix-collect-garbage -d
  '';

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Cleanup old profiles on NixOS";
    license = lib.licenses.free;
    mainProgram = name;
  };
}
