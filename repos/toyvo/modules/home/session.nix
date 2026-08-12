{
  config,
  lib,
  pkgs,
  system,
  ...
}:
let
  cfg = config.nixcfg.session;
in
{
  options = {
    nixcfg.session.enable = lib.mkEnableOption "session configuration";
  };

  config = lib.mkIf cfg.enable {
    programs.home-manager.enable = true;

    home = {
      stateVersion = "26.11";
      enableNixpkgsReleaseCheck = false;
      sessionPath =
        lib.optionals config.programs.volta.enable [
          "${config.programs.volta.voltaHome}/bin"
        ]
        ++ [
          "${config.home.homeDirectory}/.cargo/bin"
          "${config.home.homeDirectory}/.local/bin"
          "${config.home.homeDirectory}/.bin"
          "${config.home.homeDirectory}/bin"
          "/run/wrappers/bin"
          "${config.home.homeDirectory}/.nix-profile/bin"
          "/nix/profile/bin"
          "${config.home.homeDirectory}/.local/state/nix/profile/bin"
          "/etc/profiles/per-user/${config.home.username}/bin"
          "/run/current-system/sw/bin"
          "/nix/var/nix/profiles/default/bin"
        ]
        ++ lib.optionals (system == "aarch64-darwin") [
          "/opt/homebrew/bin"
          "/opt/homebrew/sbin"
        ]
        ++ lib.optionals pkgs.stdenv.isDarwin [
          "/System/Cryptexes/App/usr/bin"
        ]
        ++ [
          "/usr/local/bin"
          "/usr/local/sbin"
          "/usr/bin"
          "/usr/sbin"
          "/bin"
          "/sbin"
          "/usr/local/games"
          "/usr/games"
        ]
        ++ lib.optionals pkgs.stdenv.isDarwin [
          "/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin"
          "/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin"
          "/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin"
          "/Library/Apple/usr/bin"
        ];
    };

    xdg.configFile = {
      "nix/nix.conf".text = ''
        experimental-features = nix-command flakes pipe-operators
        substituters = https://cache.nixos.org https://nix-community.cachix.org https://cache.toyvo.dev
        trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs= cache.toyvo.dev:6bv4Qc2/SVaWnWzDOUcoB4pT3i3l4wcM+WrhRBFb7E4=
      '';
      "nixpkgs/config.nix".text = ''
        {
          allowUnfree = true;
          allowBroken = true;
        }
      '';
    };
  };
}
