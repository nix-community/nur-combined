{
  git = ./git.nix;
  github = ./github.nix;
  bitbucket = ./bitbucket.nix;
  sshd = ./sshd.nix;
  ssh = ./ssh.nix;
  konawall = ./konawall.nix;
  task = ./task.nix;
  kakoune = ./kakoune.nix;
  rustfmt = ./rustfmt.nix;
  base16 = import ./base16.nix false;
  base16-shell = ./base16-shell.nix;
  filebin = ./filebin.nix;
  display = ./display.nix;
  buku = ./buku.nix;
  i3 = ./i3.nix;
  i3gopher = ./i3gopher.nix;
  lorri = ./lorri.nix;
  shell = ./shell.nix;
  less = ./less.nix;
  tridactyl = ./tridactyl.nix;
  ncpamixer = ./ncpamixer.nix;
  nix-path = ./nix-path.nix;
  offlineimap = ./offlineimap.nix;
  weechat = ./weechat.nix;
  systemd = ./systemd.nix;

  __functionArgs = { };
  __functor = self: { ... }: {
    imports = with self; [
      git github bitbucket
      sshd ssh
      konawall
      task
      kakoune
      rustfmt
      base16 base16-shell
      filebin
      display
      buku
      i3 i3gopher
      lorri
      shell
      less
      tridactyl
      ncpamixer
      nix-path
      offlineimap
      weechat
      systemd
    ];
  };
}
