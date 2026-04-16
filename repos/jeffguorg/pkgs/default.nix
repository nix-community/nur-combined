{ pkgs, ... }:
{
  create-tauri-app = pkgs.callPackage ./create-tauri-app { };
  claude-code-bin = pkgs.callPackage ./claude-code {};
  codex = (pkgs.callPackage ./codex {}).codex;
  codex-bin = (pkgs.callPackage ./codex {}).codex-bin;
  dingtalk = pkgs.callPackage ./dingtalk { };
  kwok = pkgs.callPackage ./kwok/default.nix { };
  vagrant-vmware-utility = pkgs.callPackage ./vagrant-vmware-utility.nix {};
}
