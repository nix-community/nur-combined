# Implementing impermanence on NixOS

### Observation

Follow the ZFS/BTRFS guide before going into this one. Also, read Graham Christensen's guide first to understand the idea.

## Implementation

- Prepare your disks
- Create your system directories
  - Remember to create a `persist` directory
- Mount your volumes into the system
- Proceed into generating the configuration with `nixos-generate-config --root /mnt`
- When configuring the system, remember to reference the impermanence module. From there, configure your root volume to use `tmpfs` like this:
```
{
  # …

  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
    options = [ "defaults" "size=2G" "mode=755" ];
  };

  # …
}
```
- Set `users.mutableUsers` as false, and for each of the users created (including root), implement any of the `initialHashedPassword` or `passwordFile`.
  - If possible, follow the guide regarding secrets through `sops-nix`.
- If you need to reference persisting files or directories:
  - Use the `environment.etc.FILE.source` option to generate files on `/etc`
  - Use the module option `environment.persistence."/source/persist/path` to specify a list of directories or files.
    - Same can be applied on home manager, but with `home-manager.user.USERNAME.home.persistence."/source/persist/path`
- Save your config and keep going with the installation


## Sources
- [The basic guide to all of the impermanence ideas on NixOS](https://grahamc.com/blog/erase-your-darlings)
- [Official NixOS wiki regarding impermanence](https://nixos.wiki/wiki/Impermanence)
- [Guide to implementing it on NixOS the common way, with some examples](https://elis.nu/blog/2020/05/nixos-tmpfs-as-root/)
- [Part 2 of the guide above, now with the impermanence module](https://elis.nu/blog/2020/06/nixos-tmpfs-as-home/)