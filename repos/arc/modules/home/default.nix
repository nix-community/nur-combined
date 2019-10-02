{
  imports = [
    ./git.nix
    ./github.nix
    ./sshd.nix
    ./konawall.nix
    ./task.nix
    ./kakoune.nix
    ./rustfmt.nix
    ./base16-shell.nix
    (import ./base16.nix false)
    ./symlink.nix
    ./filebin.nix
    ./i3.nix
    ./i3gopher.nix
    ./lorri.nix
    ./shell.nix
    ./less.nix
    ./tridactyl.nix
    ./nix-path.nix
    ./weechat.nix
    (import ../nixos/keychain.nix false)
  ];
}
