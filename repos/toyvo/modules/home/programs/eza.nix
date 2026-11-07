{ config, lib, ... }:
let
  cfg = config.programs.eza;
  aliases = {
    ls = "eza";
    ll = "eza -lgo";
    la = "eza -a";
    lt = "eza -T";
    lla = "eza -lago";
    lta = "eza -Ta";
    llta = "eza -lTago";
  };
in
{
  config = lib.mkIf cfg.enable {
    programs = {
      bash.shellAliases = aliases;
      zsh.shellAliases = aliases;
      fish.shellAliases = aliases;
      powershell.shellAliases = aliases;
      # eza.enableAliases adds aliases to nushell which is unwanted
      nushell.shellAliases = aliases // {
        ls = lib.mkForce "ls";
        ll = lib.mkForce "ls -l";
        la = lib.mkForce "ls -a";
        lla = lib.mkForce "ls -la";
      };
    };
  };
}
