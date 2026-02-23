{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ../os
    ./podman.nix
    ./ollama.nix
  ];
  config = lib.mkIf config.profiles.defaults.enable {
    security.pam.services.sudo_local.touchIdAuth = true;
    system = {
      stateVersion = 6;
      keyboard = {
        enableKeyMapping = true;
        remapCapsLockToControl = true;
      };
      primaryUser = config.userPresets.toyvo.name;
    };
    environment.variables.TERMINFO_DIRS = lib.mkForce (
      map (path: path + "/share/terminfo") config.environment.profiles
      ++ [
        "/usr/share/terminfo"
        # Add ghostty terminfo from homebrew
        "/Applications/Ghostty.app/Contents/Resources/terminfo"
      ]
    );
    programs = {
      bash = {
        enable = true;
        # enableCompletion isn't compatible with uutils-coreutils-noprefix because when both uutils-coreutils-noprefix and
        # bash-completion are installed into systemPackages, there are bash completions that collide.
        # I've taken the text from nixpkgs instead of nix-darwin, they are the same except for the if statement.
        interactiveShellInit = ''
          # Check whether we're running a version of Bash that has support for
          # programmable completion. If we do, enable all modules installed in
          # the system and user profile in obsolete /etc/bash_completion.d/
          # directories. Bash loads completions in all
          # $XDG_DATA_DIRS/bash-completion/completions/
          # on demand, so they do not need to be sourced here.
          if shopt -q progcomp &>/dev/null; then
            . "${pkgs.bash-completion}/etc/profile.d/bash_completion.sh"
            nullglobStatus=$(shopt -p nullglob)
            shopt -s nullglob
            for p in $NIX_PROFILES; do
              for m in "$p/etc/bash_completion.d/"*; do
                . "$m"
              done
            done
            eval "$nullglobStatus"
            unset nullglobStatus p m
          fi
        '';
      };
    };
    homebrew = {
      enable = true;
      onActivation = {
        autoUpdate = true;
        upgrade = true;
        cleanup = "zap";
      };
      casks = [
        {
          name = "firefox";
        }
        {
          name = "ghostty";
        }
        {
          name = "jetbrains-toolbox";
        }
        {
          name = "onlyoffice";
        }
        {
          name = "podman-desktop";
        }
        {
          name = "proton-drive";
        }
        {
          name = "proton-mail";
        }
        {
          name = "proton-pass";
        }
        {
          name = "protonvpn";
        }
      ];
    };
  };
}
