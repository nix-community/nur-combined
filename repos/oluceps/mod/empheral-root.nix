{ self, inputs, ... }:
{
  flake.modules.nixos.empheral-root =
    { pkgs, config, ... }:
    {
      imports = [ inputs.preservation.nixosModules.default ];
      preservation = {
        enable = true;
        preserveAt."/persist" = {
          files = [ ];
          directories = [
            # no /var since regular mount
          ];

          users = {
            root = {
              home = "/root";
              directories = [
                {
                  directory = ".ssh";
                  mode = "0700";
                }
              ];
              files = [
                ".bash_history"
              ];
            };
          };
        };
      };

      systemd.services = {
        nix-daemon.serviceConfig = {
          # WARNING: THIS makes nix-daemon build extremely slow
          # LimitNOFILE = lib.mkForce 500000000;
          Environment = [ "TMPDIR=/var/tmp/nix-daemon" ];
        };
      };
      systemd.tmpfiles.rules = [
        "d /var/tmp/nix-daemon 0755 root root -"
        "C /var/cache/tuigreet/lastuser - - - - ${pkgs.writeText "lastuser" "${config.identity.user}"}"
        "L /home/${config.identity.user}/.nix-profile - - - - /home/${config.identity.user}/.local/state/nix/profiles/profile"

        "L /home/${config.identity.user}/.blerc - - - - ${pkgs.writeText "blerc" ''
          bleopt term_true_colors=none
          bleopt prompt_ruler=empty-line
          ble-face -s command_builtin_dot       fg=yellow,bold
          ble-face -s command_builtin           fg=yellow
          ble-face -s filename_directory        underline,fg=magenta
          ble-face -s filename_directory_sticky underline,fg=white,bg=magenta
          ble-face -s command_function          fg=blue

          function ble/prompt/backslash:my/starship-right {
            local right
            ble/util/assign right '${pkgs.starship}/bin/starship prompt --right'
            ble/prompt/process-prompt-string "$right"
          }
          bleopt prompt_rps1="\n\n\q{my/starship-right}"
          bleopt prompt_ps1_final="\033[1m=>\033[0m "
          bleopt prompt_rps1_transient="same-dir"
        ''}"

      ];
    };
  flake.modules.nixos.empheral-root-full =
    { config, ... }:
    {
      imports = [ self.modules.nixos.empheral-root ];
      preservation.preserveAt."/persist".users.${config.identity.user} = {
        files = [
          ".npmrc"
          ".mongoshrc.js"
          # ".gitconfig"
          ".bash_history"
        ];
        directories = [
          "Src"
          "Books"
          "Documents"
          "Downloads"
          "Pictures"
          "Videos"
          "Music"
          "Tools"
          "Vault"
          {
            directory = ".thunderbird";
            mode = "0700";
          }
          {
            directory = "Sec";
            mode = "0700";
          }
          ".npm-packages"
          ".npm"
          ".pip"
          ".cache"
          ".local"
          ".mc"
          ".factorio"
          ".cargo"
          ".rustup"
          ".mozilla"
          ".FeelUOwn"
          ".antigravity"
          ".config"
          ".mongodb"
          ".vscode"
          ".gradle"
          ".steam"
          ".gemini"
          "Android"
          "Games"
          {
            directory = ".gnupg";
            mode = "0700";
          }
          {
            directory = ".ssh";
            mode = "0700";
          }
        ];
      };

    };

}
