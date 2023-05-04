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
          curl
          duplicity
          file
          findutils
          git
          gnugrep
          gnused
          gocryptfs
          ifuse
          inetutils
          inotify-tools
          iwd
          jq
          ncurses
          oath-toolkit
          openssh
          openssl
          rmlint
          rsync
          ssh-to-age
          sops
          sudo
          systemd
          transmission
          util-linux
          which
        ];
        keep = {
          "/run/secrets/duplicity_passphrase" = true;
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
          "cannot:${duplicity}/bin/duplicity"
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
          "cannot:${transmission}/bin/transmission-remote"
        ];
      };
    };

    # remove python scripts  (we package them further below)
    patchPhase = builtins.concatStringsSep
      "\n"
      (lib.mapAttrsToList (name: pkg: "rm ${pkg.pname}") py-scripts)
    ;

    installPhase = ''
      mkdir -p $out/bin
      cp -R * $out/bin/
    '';
  };

  py-scripts = {
    bt-search = static-nix-shell.mkPython3Bin {
      pname = "sane-bt-search";
      src = ./src;
      pyPkgs = [ "natsort" "requests" ];
    };
    date-math = static-nix-shell.mkPython3Bin {
      pname = "sane-date-math";
      src = ./src;
    };
    reclaim-boot-space = static-nix-shell.mkPython3Bin {
      pname = "sane-reclaim-boot-space";
      src = ./src;
    };
    ip-reconnect = static-nix-shell.mkPython3Bin {
      pname = "sane-ip-reconnect";
      src = ./src;
    };
  };
in
symlinkJoin {
  name = "sane-scripts";
  paths = [ shell-scripts ] ++ lib.attrValues py-scripts;
  meta = {
    description = "collection of scripts associated with uninsane systems";
    homepage = "https://git.uninsane.org";
    platforms = lib.platforms.all;
  };
}
