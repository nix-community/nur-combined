{
  # Home Manager modules, importable individually from home configurations,
  # e.g. `inputs.nixcfg.modules.home.toyvo`. Modules declare their own
  # dependent-module `imports`; configurations import only what they use.
  # User-profile modules (`users/*`) pull in the program and `nixcfg`
  # modules they need, so a home configuration typically imports only
  # its user profile(s).
  #
  # my-module = ./my-module;
  agent = ./users/agent.nix;
  alacritty = ./programs/terminals/alacritty.nix;
  bash = ./programs/shells/bash.nix;
  bat = ./programs/bat.nix;
  briar = ./users/briar.nix;
  catppuccin = ./catppuccin.nix;
  chloe = ./users/chloe.nix;
  gui = ./gui.nix;
  eza = ./programs/eza.nix;
  fish = ./programs/shells/fish.nix;
  ghostty = ./programs/terminals/ghostty.nix;
  git = ./programs/git.nix;
  gtk = ./programs/gtk.nix;
  helix = ./programs/editors/helix.nix;
  hyper = ./programs/terminals/hyper.nix;
  ideavim = ./programs/editors/ideavim.nix;
  ion = ./programs/shells/ion.nix;
  jujutsu = ./programs/jujutsu.nix;
  kde = ./programs/kde.nix;
  kitty = ./programs/terminals/kitty.nix;
  nushell = ./programs/shells/nushell.nix;
  opencode = ./programs/editors/opencode.nix;
  pi = ./programs/pi.nix;
  powershell = ./programs/shells/powershell.nix;
  rio = ./programs/terminals/rio.nix;
  root = ./users/root.nix;
  session = ./session.nix;
  shells = ./shells.nix;
  sops = ./sops.nix;
  ssh = ./programs/ssh.nix;
  toyvo = ./users/toyvo.nix;
  volta = ./programs/volta.nix;
  wezterm = ./programs/terminals/wezterm.nix;
  zed = ./programs/editors/zed.nix;
  zsh = ./programs/shells/zsh.nix;
}
