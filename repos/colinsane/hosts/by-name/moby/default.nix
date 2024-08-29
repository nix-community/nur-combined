# Pinephone
#
# wikis, resources, ...:
# - Linux Phone Apps: <https://linuxphoneapps.org/>
#   - massive mobile-friendly app database
# - Mobian wiki: <https://wiki.mobian-project.org/doku.php?id=start>
#   - recommended apps, chatrooms

{ config, ... }:
{
  imports = [
    ./fs.nix
  ];

  sane.hal.pine64.enable = true;
  sane.roles.client = true;
  sane.roles.handheld = true;
  sane.services.wg-home.enable = true;
  sane.services.wg-home.ip = config.sane.hosts.by-name."moby".wg-home.ip;
  sane.ovpn.addrV4 = "172.24.87.255";
  # sane.ovpn.addrV6 = "fd00:0000:1337:cafe:1111:1111:18cd:a72b";

  # XXX colin: phosh doesn't work well with passwordless login,
  # so set this more reliable default password should anything go wrong
  users.users.colin.initialPassword = "147147";

  sops.secrets.colin-passwd.neededForUsers = true;

  sane.services.rsync-net.enable = true;

  sane.programs.sway.enableFor.user.colin = true;
  sane.programs.sway.config.mod = "Mod1";  #< alt key instead of Super

  # disable the following non-essential programs which fail to cross compile
  sane.programs.bash-language-server.enableFor = { system = false; user.colin = false; };  # bash neovim LSP: doesn't cross compile (2024-08-26)
  sane.programs.blueberry.enableFor.user.colin = false;  # bluetooth manager: doesn't cross compile
  sane.programs.fcitx5.enableFor.user.colin = false;
  sane.programs.ltex-ls.enableFor = { system = false; user.colin = false; };  # LaTeX/html/markdown neovim LSP: doesn't cross compile (2024-08-26)
  sane.programs.lua-language-server.enableFor = { system = false; user.colin = false; };  # lua neovim LSP: doesn't cross compile (2024-08-26)
  sane.programs.marksman.enableFor = { system = false; user.colin = false; };  # markdown neovim LSP: doesn't cross compile (2024-08-26)
  sane.programs.mercurial.enableFor.user.colin = false;
  sane.programs.nvme-cli.enableFor.system = false;  # does not cross compile (libhugetlbfs)
  sane.programs.pyright.enableFor = { system = false; user.colin = false; };  # python neovim LSP: doesn't cross compile (2024-08-26)

  # disable the following non-essential programs which are excessively slow to build or large to copy
  sane.programs.rust-analyzer.enableFor = { system = false; user.colin = false; };  # rust neovim LSP
  sane.programs.typescript-language-server.enableFor = { system = false; user.colin = false; };  # rust js/TypeScript LSP

  # enabled for easier debugging
  sane.programs.eg25-control.enableFor.user.colin = true;
  # sane.programs.rtl8723cs-wowlan.enableFor.user.colin = true;

  # sane.programs.ntfy-sh.config.autostart = true;
  sane.programs.dino.config.autostart = true;
  sane.programs.signal-desktop.config.autostart = false;
  sane.programs.geary.config.autostart = false;

  sane.programs.pipewire.config = {
    # tune so Dino doesn't drop audio
    # there's seemingly two buffers for the mic (see: <https://gitlab.freedesktop.org/pipewire/pipewire/-/wikis/FAQ#pipewire-buffering-explained>)
    # 1. Pipewire buffering out of the driver and into its own member.
    # 2. Pipewire buffering into Dino.
    # the latter is fixed at 10ms by Dino, difficult to override via runtime config.
    # the former defaults low (e.g. 512 samples)
    # this default configuration causes the mic to regularly drop out entirely for a couple seconds at a time during a call,
    # presumably because the system can't keep up (pw-top shows incrementing counter in ERR column).
    # `pw-metadata -n settings 0 clock.force-quantum 1024` reduces to about 1 error per second.
    # `pw-metadata -n settings 0 clock.force-quantum 2048` reduces to 1 error every < 10s.
    # pipewire default config includes `clock.power-of-two-quantum = true`
    min-quantum = 2048;
    max-quantum = 8192;
  };

  sane.programs.mpv.config.default_profile = "fast";

  # /boot space is at a premium. default was 20.
  # even 10 can be too much
  boot.loader.generic-extlinux-compatible.configurationLimit = 8;
}
