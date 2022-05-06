# Deleting old boot entries and profiles from NixOS

**NOTE:** ***ALWAYS*** ensure your latest NixOS build is working as intended. If you delete entries without ensuring the latest works, then it's probable that you will screw up your system and need to boot from a recovery. Be advised.
- Ah and don't use NixOS ISO with the `nixos-enter` command because of [this](https://github.com/NixOS/nixpkgs/issues/39665).
- Again, ***DON'T SCREW IT. YOU'VE BEEN ADVISED.***

## Profiles

Run as superuser `rm /nix/var/nix/profiles/system-profiles/<entries>`

## General Boot Entries

Run the following commands as superuser:
- `nix-collect-garbage --delete-older-than Nd # Replace N with a quantity of days`
- `nixos-rebuild --flake '.#' boot`
- `nixos-rebuild switch --flake '.#' # This to ensure there is a profile to boot in case you deleted all`
