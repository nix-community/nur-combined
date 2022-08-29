Here are some additional nix packages for my personal use.

Package list: https://nur.nix-community.org/repos/yes/

Currently, this repository is updated manually. If you notice any outdated packages or packaging errors, feel free to open an issue.

### Pacman
To make pacman and its dependents work, you'll probably need to set up pacman configuration files in `/etc`. On NixOS, this can be done declaratively in `configuration.nix`.

Example:

```nix
{
  environment = {
    etc = {
      "makepkg.conf".source = "${pkgs.nur.repos.yes.archlinux.devtools}/share/devtools/makepkg-x86_64.conf";
      "pacman.conf".source = "${pkgs.nur.repos.yes.archlinux.devtools}/share/devtools/pacman-extra.conf";
      "pacman.d/gnupg".source = "${pkgs.nur.repos.yes.archlinux.pacman-gnupg}/etc/pacman.d/gnupg";
      "pacman.d/mirrorlist".text = ''
        Server = https://mirrors.bfsu.edu.cn/archlinux/$repo/os/$arch
        Server = https://m.mirrorz.org/archlinux/$repo/os/$arch
        Server = https://mirror.sjtu.edu.cn/archlinux/$repo/os/$arch
      '';
    };
  };
}
```

#### devtools
See [wiki](https://github.com/SamLukeYes/nix-custom-packages/wiki/Arch-Linux-devtools) for testing status. You can update the list directly by editing the wiki page.

### Flakes?
Not yet... maybe until nix flake becomes a stable feature.