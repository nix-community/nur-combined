{ lib
, pkgs
, resholve
, static-nix-shell
, symlinkJoin
}:

let
  shell-scripts = resholve.mkDerivation {
    # resholve documentation:
    # - nix: https://github.com/nixos/nixpkgs/blob/master/pkgs/development/misc/resholve/README.md
    # - generic: https://github.com/abathur/resholve
    pname = "sane-scripts";
    version = "0.1.0";

    src = ./src;

    solutions = {
      default = {
        # note: `scripts` refers to the store path here
        scripts = [ "bin/*" ];
        interpreter = "${pkgs.bash}/bin/bash";
        inputs = with pkgs; [
          # string is interpreted as relative path from @OUT@.
          # this lets our scripts reference eachother.
          # see: <https://github.com/abathur/resholve/issues/26>
          "bin"
          coreutils-full
          file
          findutils
          gnugrep
          gnused
          gocryptfs
          ifuse
          inetutils
          iwd
          jq
          oath-toolkit
          openssh
          openssl
          nix-shell-scripts.ip-check
          nix-shell-scripts.mount-servo
          rmlint
          rsync
          ssh-to-age
          sops
          sudo
          systemd
          util-linux
          which
        ];
        keep = {
          # we write here: keep it
          "/tmp/rmlint.sh" = true;
          # intentionally escapes (into user code)
          "$external_cmd" = true;
          "$maybe_sudo" = true;
        };
        fake = {
          external = [
            # https://github.com/abathur/resholve/issues/29
            # "umount"
            # "/run/wrappers/bin/sudo"
            "sudo"
          ];
        };
        fix = {
          # this replaces umount with the non-setuid-wrapper umount.
          # not sure if/where that lack of suid causes problems.
          umount = true;
        };
        prologue = "${./resholve-prologue}";

        # list of programs which *can* or *cannot* exec their arguments
        execer = with pkgs; [
          "cannot:${git}/bin/git"
          "cannot:${gocryptfs}/bin/gocryptfs"
          "cannot:${ifuse}/bin/ifuse"
          "cannot:${iwd}/bin/iwctl"
          "cannot:${oath-toolkit}/bin/oathtool"
          "cannot:${openssh}/bin/ssh-keygen"
          "cannot:${rmlint}/bin/rmlint"
          "cannot:${rsync}/bin/rsync"
          "cannot:${sops}/bin/sops"
          "cannot:${ssh-to-age}/bin/ssh-to-age"
          "cannot:${systemd}/bin/systemctl"
        ];
      };
    };

    patchPhase =
      let
        rmPy = builtins.concatStringsSep
          "\n"
          (lib.mapAttrsToList (name: pkg: "rm ${pkg.pname}") nix-shell-scripts)
        ;
      in ''
        # remove python library files, and python binaries  (those are packaged further below)
        rm -rf lib/
        ${rmPy}
      '';

    installPhase = ''
      mkdir -p $out/bin
      cp -R * $out/bin/
    '';
  };

  nix-shell-scripts = {
    # anything added to this attrset gets symlink-joined into `sane-scripts`
    backup-ls = static-nix-shell.mkBash {
      pname = "sane-backup-ls";
      src = ./src;
      pkgs = [ "duplicity" ];
    };
    backup-restore = static-nix-shell.mkBash {
      pname = "sane-backup-restore";
      src = ./src;
      pkgs = [ "duplicity" ];
    };
    bt-add = static-nix-shell.mkBash {
      pname = "sane-bt-add";
      src = ./src;
      pkgs = [ "transmission" ];
    };
    bt-rm = static-nix-shell.mkBash {
      pname = "sane-bt-rm";
      src = ./src;
      pkgs = [ "transmission" ];
    };
    bt-search = static-nix-shell.mkPython3Bin {
      pname = "sane-bt-search";
      src = ./src;
      pyPkgs = [ "natsort" "requests" ];
    };
    bt-show = static-nix-shell.mkBash {
      pname = "sane-bt-show";
      src = ./src;
      pkgs = [ "transmission" ];
    };
    deadlines = static-nix-shell.mkBash {
      pname = "sane-deadlines";
      src = ./src;
      pkgs = [ "coreutils-full" ];
    };
    dev-cargo-loop = static-nix-shell.mkBash {
      pname = "sane-dev-cargo-loop";
      src = ./src;
      pkgs = [ "inotify-tools" "ncurses" ];
    };
    find-dotfiles = static-nix-shell.mkBash {
      pname = "sane-find-dotfiles";
      src = ./src;
      pkgs = [ "findutils" ];
    };
    git-init = static-nix-shell.mkBash {
      pname = "sane-git-init";
      src = ./src;
      pkgs = [ "git" ];
    };
    ip-check = static-nix-shell.mkBash {
      pname = "sane-ip-check";
      src = ./src;
      pkgs = [ "curl" "gnugrep" ];
    };
    ip-check-upnp = static-nix-shell.mkPython3Bin {
      pname = "sane-ip-check-upnp";
      src = ./src;
      pkgs = [ "miniupnpc" ];
      postInstall = ''
        mkdir -p $out/bin/lib
        cp -R lib/* $out/bin/lib/
      '';
    };
    ip-port-forward = static-nix-shell.mkPython3Bin {
      pname = "sane-ip-port-forward";
      src = ./src;
      pkgs = [ "inetutils" "miniupnpc" ];
      postInstall = ''
        mkdir -p $out/bin/lib
        cp -R lib/* $out/bin/lib/
      '';
    };
    ip-reconnect = static-nix-shell.mkPython3Bin {
      pname = "sane-ip-reconnect";
      src = ./src;
    };
    mount-servo = static-nix-shell.mkBash {
      pname = "sane-mount-servo";
      src = ./src;
      pkgs = [ "coreutils-full" ];
    };
    mount-servo-root = static-nix-shell.mkBash {
      pname = "sane-mount-servo-root";
      src = ./src;
      pkgs = [ "coreutils-full" ];
    };
    reclaim-boot-space = static-nix-shell.mkPython3Bin {
      pname = "sane-reclaim-boot-space";
      src = ./src;
    };
  };
in
symlinkJoin {
  name = "sane-scripts";
  paths = [ shell-scripts ] ++ lib.attrValues nix-shell-scripts;
  meta = {
    description = "collection of scripts associated with uninsane systems";
    homepage = "https://git.uninsane.org";
    platforms = lib.platforms.all;
  };
}
