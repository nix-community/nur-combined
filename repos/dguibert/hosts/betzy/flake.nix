{
  description = "A flake for building my NUR packages on GENJI";

  # To update all inputs:
  # $ nix flake update --recreate-lock-file
  inputs = {
    nixpkgs.url = "github:dguibert/nixpkgs/pu-cluster";

    nix.url = "github:dguibert/nix/pu";
    #nix.url              = "github:dguibert/nix/a828ef7ec896e4318d62d2bb5fd391e1aabf242e";
    nix.inputs.nixpkgs.follows = "nixpkgs";

    flake-utils.url = "github:numtide/flake-utils";

    home-manager. url = "github:dguibert/home-manager/pu";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    base16-nix = {
      url = "github:dguibert/base16-nix";
      flake = false;
    };
    # For accessing `deploy-rs`'s utility Nix functions
    deploy-rs.url = "github:dguibert/deploy-rs/pu";
    #deploy-rs.inputs.naersk.inputs.nixpkgs.follows = "nixpkgs";
    deploy-rs.inputs.nixpkgs.follows = "nixpkgs";

    nxsession.url = "github:dguibert/nxsession";
    nxsession.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    nix,
    flake-utils,
    home-manager,
    base16-nix,
    deploy-rs,
    ...
  } @ inputs: let
    # Memoize nixpkgs for different platforms for efficiency.
    nixpkgsFor = system:
      import nixpkgs {
        localSystem = {
          inherit system;
          # gcc = { arch = "x86-64" /*target*/; };
        };
        overlays = [
          nix.overlay
          deploy-rs.overlay
          overlays.default
          overlays.aocc
          overlays.flang
          overlays.intel-compilers
          overlays.arm
          overlays.pgi
          (import ../../envs/overlay.nix nixpkgs)
          (import ../../emacs/overlay.nix)
          self.overlays.default
          inputs.nxsession.overlay
        ];
        config = {
          replaceStdenv = import ../../stdenv.nix;
          allowUnfree = true;
        };
      };

    overlays = import ../../overlays;

    NIX_CONF_DIR_fun = pkgs: let
      nixConf = pkgs.writeTextDir "opt/nix.conf" ''
        max-jobs = 8
        cores = 0
        sandbox = false
        auto-optimise-store = true
        require-sigs = true
        trusted-users = nixBuild dguibert
        allowed-users = *

        system-features = recursive-nix nixos-test benchmark big-parallel kvm
        sandbox-fallback = false

        keep-outputs = true       # Nice for developers
        keep-derivations = true   # Idem
        extra-sandbox-paths = /opt/intel/licenses=/home/dguibert/nur-packages/secrets?
        experimental-features = nix-command flakes recursive-nix
        system-features = recursive-nix nixos-test benchmark big-parallel gccarch-x86-64 kvm
        #extra-platforms = i686-linux aarch64-linux

        #builders = @/tmp/nix--home_nfs-dguibert-machines
        extra-substituters = local?root=/mnt/old/cluster/projects/nn9560k/dguibert&trusted=1
      '';
    in "${nixConf}/opt";
  in
    (flake-utils.lib.eachSystem ["x86_64-linux" "aarch64-linux"] (system: let
      pkgs = nixpkgsFor system;
    in rec {
      legacyPackages = pkgs;

      apps.default = apps.nix;
      apps.nix = flake-utils.lib.mkApp {
        drv = pkgs.writeScriptBin "nix-spartan" (with pkgs; let
          name = "nix-${builtins.replaceStrings ["/"] ["-"] nixStore}";
          NIX_CONF_DIR = NIX_CONF_DIR_fun pkgs;
          # https://gist.githubusercontent.com/cleverca22/bc86f34cff2acb85d30de6051fa2c339/raw/03a36bbced6b3ae83e46c9ea9286a3015e8285ee/doit.sh
          # NIX_REMOTE=local?root=/home/clever/rootfs/
          # NIX_CONF_DIR=/home/$X/etc/nix
          # NIX_LOG_DIR=/home/$X/nix/var/log/nix
          # NIX_STORE=/home/$X/nix/store
          # NIX_STATE_DIR=/home/$X/nix/var
          # nix-build -E 'with import <nixpkgs> {}; nix.override { storeDir = "/home/'$X'/nix/store"; stateDir = "/home/'$X'/nix/var"; confDir = "/home/'$X'/etc"; }'
        in ''
          #!${runtimeShell}
          set -x
          export XDG_CACHE_HOME=$HOME/.cache/${name}
          export NIX_STORE=${nixStore}/store
          export PATH=${pkgs.nix}/bin:$PATH
          $@
        '');
      };

      devShells.default = with pkgs;
        mkShell rec {
          name = "nix-${builtins.replaceStrings ["/"] ["-"] nixStore}";
          ENVRC = "nix-${builtins.replaceStrings ["/"] ["-"] nixStore}";
          nativeBuildInputs = [
            pkgs.nix
            jq
            pkgs.deploy-rs.deploy-rs
            #deploy-rs.packages.${system}.deploy-rs
          ];
          shellHook = ''
            export ENVRC=${name}
            export XDG_CACHE_HOME=$HOME/.cache/${name}
            export NIX_STORE=${nixStore}/store
            unset TMP TMPDIR TEMPDIR TEMP
            unset NIX_PATH

          '';
          NIX_CONF_DIR = NIX_CONF_DIR_fun pkgs;
        };

      homeConfigurations.home-dguibert = home-manager.lib.homeManagerConfiguration {
        username = "dguibert";
        homeDirectory = "/cluster/home/dguibert";
        inherit system pkgs;
        configuration = {lib, ...}: {
          imports = [
            ({...}: {
              home.sessionVariablesFileName = "hm-session-vars.sh";
              home.sessionVariablesGuardVar = "__HM_SESS_VARS_SOURCED";
              home.pathName = "home-manager-path";
              home.gcLinkName = "current-home";
              home.generationLinkNamePrefix = "home-manager";
            })
            ({
              config,
              pkgs,
              lib,
              ...
            }: {
              nix.package = pkgs.nixStable;
              services.gpg-agent.pinentryFlavor = lib.mkForce "curses";
              home.packages = with pkgs; [
                pkgs.nix
              ];
              programs.bash.enable = true;
              programs.bash.profileExtra = ''
                if [ -e $HOME/.home-$(uname -m)/.profile ]; then
                  source $HOME/.home-$(uname -m)/.profile
                fi
              '';
              programs.bash.bashrcExtra = ''
                if [ -e $HOME/.home-$(uname -m) ]; then
                    if [ -n "$HOME" ] && [ -n "$USER" ]; then

                        # Set up the per-user profile.
                        # This part should be kept in sync with nixpkgs:nixos/modules/programs/shell.nix

                        NIX_LINK=$HOME/.home-$(uname -m)/.nix-profile

                        # Set up environment.
                        # This part should be kept in sync with nixpkgs:nixos/modules/programs/environment.nix
                        export NIX_PROFILES="/home_nfs/dguibert/nix/var/nix/profiles/default $NIX_LINK"

                        # Set $NIX_SSL_CERT_FILE so that Nixpkgs applications like curl work.
                        if [ -e /etc/ssl/certs/ca-certificates.crt ]; then # NixOS, Ubuntu, Debian, Gentoo, Arch
                             export NIX_SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt
                        elif [ -e /etc/ssl/ca-bundle.pem ]; then # openSUSE Tumbleweed
                             export NIX_SSL_CERT_FILE=/etc/ssl/ca-bundle.pem
                        elif [ -e /etc/ssl/certs/ca-bundle.crt ]; then # Old NixOS
                             export NIX_SSL_CERT_FILE=/etc/ssl/certs/ca-bundle.crt
                        elif [ -e /etc/pki/tls/certs/ca-bundle.crt ]; then # Fedora, CentOS
                             export NIX_SSL_CERT_FILE=/etc/pki/tls/certs/ca-bundle.crt
                        elif [ -e "$NIX_LINK/etc/ssl/certs/ca-bundle.crt" ]; then # fall back to cacert in Nix profile
                             export NIX_SSL_CERT_FILE="$NIX_LINK/etc/ssl/certs/ca-bundle.crt"
                        elif [ -e "$NIX_LINK/etc/ca-bundle.crt" ]; then # old cacert in Nix profile
                             export NIX_SSL_CERT_FILE="$NIX_LINK/etc/ca-bundle.crt"
                        fi

                        if [ -n "''${MANPATH-}" ]; then
                            export MANPATH="$NIX_LINK/share/man:$MANPATH"
                        fi

                        export PATH="$NIX_LINK/bin:$PATH"
                        unset NIX_LINK
                    fi
                fi
                if ! command -v nix &>/dev/null; then
                    if [ -e $HOME/.nix-profile/etc/profile.d/nix.sh ]; then
                      source $HOME/.nix-profile/etc/profile.d/nix.sh
                    fi
                    export NIX_IGNORE_SYMLINK_STORE=1 # aloy
                fi

                export NIX_IGNORE_SYMLINK_STORE=1 # aloy

                if [ -e $HOME/.home-$(uname -m)/.bashrc ]; then
                    source $HOME/.home-$(uname -m)/.bashrc
                fi
                case $HOSTNAME in
                  l0|genji0)
                  ;;
                  genji*|c*|g*|spartan*)
                  export TMP=/dev/shm; export TMPDIR=$TMP; export TEMP=$TMP; export TEMPDIR=$TMP
                  ;;
                esac
              '';
              home.file.".inputrc".text = ''
                set show-all-if-ambiguous on
                set visible-stats on
                set page-completions off
                # https://git.suckless.org/st/file/FAQ.html
                set enable-keypad on
                # http://www.caliban.org/bash/
                #set editing-mode vi
                #set keymap vi
                #Control-o: ">&sortie"
                "\e[A": history-search-backward
                "\e[B": history-search-forward
                "\e[1;5A": history-search-backward
                "\e[1;5B": history-search-forward

                # Arrow keys in keypad mode
                "\C-[OA": history-search-backward
                "\C-[OB": history-search-forward
                "\C-[OC": forward-char
                "\C-[OD": backward-char

                # Arrow keys in ANSI mode
                "\C-[[A": history-search-backward
                "\C-[[B": history-search-forward
                "\C-[[C": forward-char
                "\C-[[D": backward-char

                # mappings for Ctrl-left-arrow and Ctrl-right-arrow for word moving
                "\e[1;5C": forward-word
                "\e[1;5D": backward-word
                #"\e[5C": forward-word
                #"\e[5D": backward-word
                "\e\e[C": forward-word
                "\e\e[D": backward-word

                $if mode=emacs

                # for linux console and RH/Debian xterm
                "\e[1~": beginning-of-line
                "\e[4~": end-of-line
                "\e[5~": beginning-of-history
                "\e[6~": end-of-history
                "\e[7~": beginning-of-line
                "\e[3~": delete-char
                "\e[2~": quoted-insert
                "\e[5C": forward-word
                "\e[5D": backward-word
                "\e\e[C": forward-word
                "\e\e[D": backward-word
                "\e[1;5C": forward-word
                "\e[1;5D": backward-word

                # for rxvt
                "\e[8~": end-of-line

                # for non RH/Debian xterm, can't hurt for RH/DEbian xterm
                "\eOH": beginning-of-line
                "\eOF": end-of-line

                # for freebsd console
                "\e[H": beginning-of-line
                "\e[F": end-of-line
                $endif
              '';

              # mimeapps.list
              # https://github.com/bobvanderlinden/nix-home/blob/master/home.nix
              home.keyboard.layout = "fr";
            })
          ];
          _module.args.pkgs = lib.mkForce pkgs;
        };
      };

      homeConfigurations.home-dguibert-x86_64 = home-manager.lib.homeManagerConfiguration {
        username = "dguibert";
        homeDirectory = "/cluster/home/dguibert/.home-x86_64";
        inherit system pkgs;
        configuration = {lib, ...}: {
          imports = [
            (import "${base16-nix}/base16.nix")
            (import ./home-dguibert.nix)
            ({...}: {
              home.sessionVariablesFileName = "hm-x86_64-session-vars.sh";
              home.sessionVariablesGuardVar = "__HM_X86_64_SESS_VARS_SOURCED";
              home.pathName = "home-manager-x86_64_path";
              home.gcLinkName = "current-home-x86_64";
              home.generationLinkNamePrefix = "home-manager-x86_64";
            })
          ];
          _module.args.pkgs = lib.mkForce pkgs;
        };
      };
    }))
    // {
      overlays.default = final: prev: import ./overlay.nix final prev;

      deploy.nodes.betzy = {
        hostname = "betzy.sigma2.no";
        # Fast connection to the node. If this is true, copy the whole closure instead of letting the node substitute.
        # This defaults to `false`
        fastConnection = true;

        # If the previous profile should be re-activated if activation fails.
        autoRollback = true;

        # See the earlier section about Magic Rollback for more information.
        # This defaults to `true`
        magicRollback = false;

        profilesOrder = [
          "hm-dguibert-x86_64"
          "hm-dguibert"
        ];
        profiles.hm-dguibert = {
          user = "dguibert";
          sshUser = "dguibert";
          path =
            (nixpkgsFor "x86_64-linux").deploy-rs.lib.activate.custom self.homeConfigurations.x86_64-linux.home-dguibert.activationPackage
            ''              export NIX_STATE_DIR=${self.legacyPackages.x86_64-linux.nixStore}/var/nix
                          export HOME_MANAGER_BACKUP_EXT=bak
                          nix-env --set-flag priority 80 nix
                          ./activate
            '';
          profilePath = "${self.legacyPackages.x86_64-linux.nixStore}/var/nix/profiles/per-user/dguibert/hm";
        };
        profiles.hm-dguibert-x86_64 = {
          user = "dguibert";
          sshUser = "dguibert";
          path =
            (nixpkgsFor "x86_64-linux").deploy-rs.lib.activate.custom self.homeConfigurations.x86_64-linux.home-dguibert-x86_64.activationPackage
            ''
              set -x
              export NIX_STATE_DIR=${self.legacyPackages.x86_64-linux.nixStore}/var/nix
              export NIX_PROFILE=${self.legacyPackages.x86_64-linux.nixStore}/var/nix/profiles/per-user/dguibert/profile-x86_64
              export HOME=${self.homeConfigurations.x86_64-linux.home-dguibert-x86_64.config.home.homeDirectory}
              export PATH=${self.legacyPackages.x86_64-linux.nix}/bin:$PATH
              mkdir -p $HOME
              rm -rf $HOME/.nix-profile
              ln -sf $NIX_PROFILE $HOME/.nix-profile
               ./activate
              set +x
            '';
          profilePath = "${self.legacyPackages.x86_64-linux.nixStore}/var/nix/profiles/per-user/dguibert/hm-x86_64";
        };
      };

      # This is highly advised, and will prevent many possible mistakes
      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    };
}
