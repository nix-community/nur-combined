{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.profiles;
in
{
  config = lib.mkIf cfg.defaults.enable {
    programs = {
      zsh.enable = true;
      fish.enable = true;
      nh = {
        enable = true;
        flake = "${config.users.users.${config.userPresets.toyvo.name}.home}/nixcfg";
        clean.enable = true;
      };
    };
    environment =
      let
        shells = with pkgs; [
          bashInteractive
          fish
          nushell
          powershell
          zsh
        ];
      in
      {
        inherit shells;
        systemPackages =
          with pkgs;
          shells
          ++ [
            age
            broot
            cachix
            curl
            curlie
            dig
            doggo
            dotnet-sdk_8
            fd
            gnutar
            gping
            graphviz
            gzip
            helix
            httpie
            jq
            just
            kubectl
            lsof
            netcat
            nix-output-monitor
            nixfmt
            nmap
            nvd
            openssh
            openssl
            rclone
            ripgrep
            rsync
            sops
            sqlite
            tlrc
            unzip
            uutils-coreutils-noprefix
            wget
            xz
            zip
            zstd
          ]
          ++ lib.optionals stdenv.isLinux [
            aha
            clinfo
            fwupd
            mesa-demos
            pciutils
            vulkan-tools
            wayland-utils
            yubico-piv-tool
            yubikey-manager
            yubikey-personalization
          ];
      };

    services.netbird.enable = true;
  };
}
