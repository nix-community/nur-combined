{ config, lib, options, pkgs, sane-lib, ... }:

let
  sane-user-cfg = config.sane.user;
  cfg = config.sane.users;
  path-lib = sane-lib.path;
  serviceType = with lib; types.submodule ({ config, ... }: {
    options = {
      description = mkOption {
        # XXX: has to be defaulted so consumers can set specific attributes of a service which was defined from a different nix module.
        # but swallow the default, because we want to still enforce that it's set *somewhere*.
        # type = types.str // {
        #   merge = loc: defs: types.str.merge
        #     loc
        #     (builtins.filter (v: v != "") defs)
        #   ;
        # };
        type = lib.mkOptionType {
          merge = loc: defs: types.str.merge
            loc
            (if builtins.length defs == 1 then defs
              else builtins.filter (def: def.value != "") defs
            )
          ;
          name = "defaultable str";
        };
        default = "";
      };
      documentation = mkOption {
        type = types.listOf types.str;
        default = [];
        description = ''
          references and links for where to find documentation about this service.
        '';
      };
      depends = mkOption {
        type = types.listOf types.str;
        default = [];
      };
      dependencyOf = mkOption {
        type = types.listOf types.str;
        default = [];
      };
      partOf = mkOption {
        type = types.listOf types.str;
        default = [];
        description = ''
          "bundles" to which this service belongs.
          e.g. `partOf = [ "default" ];` describes services which should be started "by default".
        '';
      };

      command = mkOption {
        type = types.nullOr (types.coercedTo types.package toString types.str);
        default = null;
        description = ''
          long-running command which represents this service.
          when the command returns, the service is considered "failed", and restarted unless explicitly `down`d.
        '';
      };
      cleanupCommand = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          command which is run after the service has exited.
          restart of the service (if applicable) is blocked on this command.
        '';
      };
      startCommand = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          command which is run to start the service.
          this command is expected to exit once the service is up, contrary to the normal `command` argument.
          mutually exclusive to `command`.
        '';
      };
      readiness.waitCommand = mkOption {
        type = types.nullOr (types.coercedTo types.package toString types.str);
        default = null;
        description = ''
          command or path to executable which exits zero only when the service is ready.
          this may be invoked repeatedly (with delay),
          though it's not an error for it to block either (it may, though, be killed and restarted if it blocks too long)
        '';
      };
      readiness.waitDbus = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          name of the dbus name this service is expected to register.
          only once the name is registered will the service be considered "ready".
        '';
      };
      readiness.waitExists = mkOption {
        type = types.coercedTo types.str toList (types.listOf types.str);
        default = [];
        description = ''
          path to a directory or file whose existence signals the service's readiness.
          this is expanded as a shell expression, and may contain variables like `$HOME`, etc.
        '';
      };

      restartCondition = mkOption {
        type = types.enum [ "always" "on-failure" ];
        default = "always";
        description = ''
          when `command` exits, under which condition should it be restarted v.s. should the service be considered down.
          - "always":  restart the service whenever it exits.
          - "on-failure"  restart the service only if `command` exits non-zero.

          note that service restarts are not instantaneous, but have some delay (e.g. 1s).
        '';
      };

      reapChildren = mkOption {
        type = types.bool;
        default = true;
        description = ''
          when the service is stopped, enforce that it leaves behind no children?

          if set false, then lingering children are reparented directly to the service manager.
        '';
      };
    };
    config = {
      readiness.waitCommand = lib.mkMerge [
        (lib.mkIf (config.readiness.waitDbus != null)
          ''${lib.getExe' pkgs.systemdMinimal "busctl"} --user status "${config.readiness.waitDbus}" > /dev/null''
        )
        (lib.mkIf (config.readiness.waitExists != [])
          # e.g.: test -e /foo -a -e /bar
          ("test -e " + (lib.concatStringsSep " -a -e " config.readiness.waitExists))
        )
      ];
    };
  });
  userOptions = with lib; {
    fs = mkOption {
      # map to listOf attrs so that we can allow multiple assigners to the same path
      # w/o worrying about merging at this layer, and defer merging to modules/fs instead.
      type = types.attrsOf (types.coercedTo types.attrs (a: [ a ]) (types.listOf types.attrs));
      default = {};
      description = ''
        entries to pass onto `sane.fs` after prepending the user's home-dir to the path.

        conventions are similar as to toplevel `sane.fs`. so `sane.users.foo.fs."/"` represents the home directory,
        whereas every other entry is expected to *not* have a trailing slash.

        option merging happens inside `sane.fs`, so `sane.users.colin.fs."foo" = A` and `sane.fs."/home/colin/foo" = B`
        behaves identically to `sane.fs."/home/colin/foo" = lib.mkMerge [ A B ];
        (the unusual signature for this type is how we delay option merging)
      '';
    };

    persist = mkOption {
      type = options.sane.persist.sys.type;
      default = {};
      description = ''
        entries to pass onto `sane.persist.sys` after prepending the user's home-dir to the path.
      '';
    };

    environment = mkOption {
      type = types.attrsOf types.str;
      default = {};
      description = ''
        environment variables to place in user's shell profile.
        these end up in ~/.profile
      '';
    };

    services = mkOption {
      type = types.attrsOf serviceType;
      default = {};
      description = ''
        services to define for this user.
      '';
    };
    serviceManager = mkOption {
      type = types.nullOr (types.enum [ "s6" "systemd" ]);
      default = "systemd";
      description = ''
        which service manager to plumb `services` into.
      '';
    };
  };
  userModule = let
    nixConfig = config;
  in with lib; types.submodule ({ name, config, ... }: {
    options = userOptions // {
      default = mkOption {
        type = types.bool;
        default = false;
        description = ''
          only one default user may exist.
          this option determines what the `sane.user` shorthand evaluates to.
        '';
      };

      home = mkOption {
        type = types.str;
        # XXX: we'd prefer to set this to `config.users.users.home`, but that causes infinite recursion...
        # TODO: maybe assert that this matches the actual home?
        default = "/home/${name}";
      };
    };

    config = lib.mkMerge [
      # if we're the default user, inherit whatever settings were routed to the default user
      (lib.mkIf config.default {
        inherit (sane-user-cfg) fs environment persist services;
      })
      {
        fs."/".dir.acl = {
          user = lib.mkDefault name;
          group = lib.mkDefault nixConfig.users.users."${name}".group;
          # homeMode defaults to 700; notice: no leading 0
          mode = "0" + nixConfig.users.users."${name}".homeMode;
        };

        # ~/.config/environment.d/*.conf is added to systemd user units.
        # - format: lines of: `key=value`
        # ~/.profile is added by *some* login shells.
        # - format: lines of: `export key="value"`
        # see: `man environment.d`
        ### normally a session manager (like systemd) would set these vars (at least) for me:
        # - XDG_RUNTIME_DIR
        # - XDG_SESSION_ID
        #   - e.g. `1`, or `2`. these aren't supposed to be reused during the same power cycle (whatever reuse means), and are used by things like `pipewire`'s context
        #   - doesn't have to be numeric, could be "colin"
        # - XDG_SESSION_CLASS
        #   - e.g. "user"
        # - XDG_SESSION_DESKTOP
        #   - e.g. "Phosh"
        # - XDG_SESSION_TYPE
        #   - e.g. "tty", "wayland"
        # - XDG_VTNR
        #   - e.g. `1`, or `2`. corresponds to some /dev/ttyN.
        # - SYSTEMD_EXEC_PID
        # some of my program-specific environment variables depend on some of these being set,
        # hence do that early:
        # TODO: consider moving XDG_RUNTIME_DIR to $HOME/.run
        environment.HOME = config.home;
        environment.USER = name;  #< something sets this by default; importing it into Nix here lets me use it in my service manager though.
        environment.XDG_RUNTIME_DIR = "/run/user/${name}";
        # XDG_DATA_DIRS gets set by shell init somewhere, but needs to be explicitly set here so it's available to services too.
        environment.XDG_DATA_DIRS = "/etc/profiles/per-user/${name}/share:/run/current-system/sw/share";
        # fs.".config/environment.d/10-sane-baseline.conf".symlink.text = ''
        #   HOME=${config.home}
        #   XDG_RUNTIME_DIR=/run/user/${name}
        # '';

        # allow env vars to refer to eachother (just re-evaluate them a couple times to compute a fix point, right? :P)
        fs.".config/environment.d/21-sane-nixos-users-fix1.conf".symlink.target = "20-sane-nixos-users.conf";
        fs.".config/environment.d/22-sane-nixos-users-fix2.conf".symlink.target = "20-sane-nixos-users.conf";

        fs.".config/environment.d/20-sane-nixos-users.conf".symlink.text =
          let
            env = lib.mapAttrsToList
              # partially escape shell expressions.
              # want the user to be able to leverage variable expansion (e.g. X=$Y), so DON'T escape `$`.
              # but we want the result to be a valid assignment, so DO escape things which would otherwise result in a _syntax_ error.
              (key: value: lib.escape [ " " ] ''${key}=${value}'')
              config.environment
            ;
          in
            lib.concatStringsSep "\n" env + "\n";
        fs.".profile".symlink.text = lib.mkMerge [
          (lib.mkBefore ''
            # N.B.: this file must be valid in all plausible shells.
            # it's primarily sourced by the user shell,
            # but it may actually be sourced by bash, and even by other users (notably root).
            #
            # sessionCommands: ordered sequence of functions which will be called whenever this file is sourced.
            # primarySessionCommands: additional functions which will be called only for the main session (i.e. login through GUI).
            # GUIs are expected to install a function to `primarySessionChecks` which returns true
            # if primary session initialization is desired (e.g. if this was sourced from a greeter).
            sessionCommands=()
            primarySessionCommands=()
            primarySessionChecks=()

            runCommands() {
              for c in "$@"; do
                eval "$c"
              done
            }
            initSession() {
              runCommands "''${sessionCommands[@]}"
            }
            maybeInitPrimarySession() {
              local delay=3
              if [ "$XDG_VTNR" = 1 ] \
                && (( ''${#primarySessionCommands[@]} )) \
                && echo "launching primary session commands in ''${delay}s: ''${primarySessionCommands[*]}" \
                && sleep $delay \
              ; then
                runCommands "''${primarySessionCommands[@]}"
              fi
            }

            setVTNR() {
              # some desktops (e.g. sway) need to know which virtual TTY to render to.
              # it's also nice, to guess if a user logging into the "default" tty, or
              # an auxiliary one

              local ttyPath=$(tty)
              case $ttyPath in
                (/dev/tty*)
                  export XDG_VTNR=''${ttyPath#/dev/tty}
                  ;;
                (*)
                  # for terminals running inside a compositor, we do want to explicitly clear XDG_VTNR.
                  # otherwise, sway will be launched from tty1, then the user will launch a terminal emulator inside sway, but the application will think it's running directly on tty1 (which it isn't)
                  unset XDG_VTNR
                  ;;
              esac
            }
            sessionCommands+=('setVTNR')
            # this is *probably not necessary*.
            # historically, Komikku needed to know if it was running under X or Wayland, and used XDG_SESSION_TYPE for that.
            # but unless this is a super common idiom, managing it here is just ugly.
            # setXdgSessionType() {
            #   case $(tty) in
            #     (/dev/pts*)
            #       export XDG_SESSION_TYPE=tty
            #       ;;
            #   esac
            # }
            # sessionCommands+=('setXdgSessionType')
            sourceEnv() {
              # source env vars and the like, as systemd would. `man environment.d`
              # XXX: can't use `~` or `$HOME` here as they might not be set
              local home=${lib.escapeShellArg config.home}
              for env in "$home"/.config/environment.d/*.conf; do
                # surround with `set -o allexport` since environment.d doesn't explicitly `export` their vars
                set -a
                source "$env"
                set +a
              done
            }
            sessionCommands+=('sourceEnv')
            ensurePath() {
              # later sessionCommands might expect to run user-specific binaries,
              # so make sure those are on PATH
              local userBin=/etc/profiles/per-user/$USER/bin
              if [[ ":$PATH:" != *":$userBin:"* ]]; then
                export PATH="$PATH:$userBin"
              fi
            }
            sessionCommands+=('ensurePath')

          '')
          (lib.mkAfter ''
            sessionCommands+=('maybeInitPrimarySession')

            if [ -n "''${PROFILE+profile_is_set}" ]; then
              # allow the user to override the profile or disable it completely.
              if [ -x "$PROFILE" ]; then
                source "$PROFILE"
              fi
            else
              initSession
            fi
          '')
        ];

        # a few common targets one can depend on or declare a `partOf` to.
        # for example, a wayland session provider should:
        # - declare `myService.partOf = [ "wayland" ];`
        # - and `graphical-session.partOf = [ "default" ];`
        services."default" = {
          description = "service (bundle) which is started by default upon login";
        };
        services."graphical-session" = {
          description = "service (bundle) which is started upon successful graphical login";
          # partOf = [ "default" ];
        };
        services."gps" = {
          # "cheap" location providers -- such as on-demand wifi-based triangulation -- don't need to be gated behind this.
          # grouping it like this is mostly a power-saving thing to make certain services not auto-launched
          description = "service (bundle) which provides high-precision location info (e.g. from GPS)";
        };
        services."private-storage" = {
          description = "service (bundle) which is active once the persist.private datastore has been opened";
          partOf = [ "default" ];
        };
        services."sound" = {
          description = "service (bundle) which represents functional sound input/output when active";
          # partOf = [ "default" ];
        };
        services."wayland" = {
          description = "service (bundle) which provides a wayland session";
        };
        services."x11" = {
          description = "service (bundle) which provides a x11 session (possibly via xwayland)";
        };
      }
    ];
  });
  processUser = name: defn:
    let
      prefixWithHome = lib.mapAttrs' (path: value: {
        name = path-lib.concat [ defn.home path ];
        inherit value;
      });
      mergeAttrValues = lib.mapAttrs (_path: values: lib.mkMerge values);
    in
    {
      sane.fs = {
        "/run/user/${name}" = {
          dir.acl = {
            user = lib.mkDefault name;
            group = lib.mkDefault config.users.users."${name}".group;
            # homeMode defaults to 700; notice: no leading 0
            mode = "0" + config.users.users."${name}".homeMode;
          };
        };
      } // (mergeAttrValues (prefixWithHome defn.fs));
      sane.defaultUser = lib.mkIf defn.default name;

      # `byPath` is the actual output here, computed from the other keys.
      sane.persist.sys.byPath = prefixWithHome defn.persist.byPath;
    };
in
{
  imports = [
    ./s6-rc.nix
    ./systemd.nix
  ];

  options = with lib; {
    sane.users = mkOption {
      type = types.attrsOf userModule;
      default = {};
      description = ''
        options to apply to the given user.
        the user is expected to be created externally.
        configs applied at this level are simply transformed and then merged
        into the toplevel `sane` options. it's merely a shorthand.
      '';
    };

    sane.user = mkOption {
      type = types.nullOr (types.submodule { options = userOptions; });
      default = null;
      description = ''
        options to pass down to the default user
      '';
    } // {
      _options = userOptions;
    };

    sane.defaultUser = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        the name of the default user.
        other attributes of the default user may be retrieved via
        `config.sane.users."''${config.sane.defaultUser}".<attr>`.
      '';
    };
  };
  config =
    let
      configs = lib.mapAttrsToList processUser cfg;
      num-default-users = lib.count (u: u.default) (lib.attrValues cfg);
      take = f: {
        sane.fs = f.sane.fs;
        sane.persist.sys.byPath = f.sane.persist.sys.byPath;
        sane.defaultUser = f.sane.defaultUser;
      };
    in lib.mkMerge [
      (take (sane-lib.mkTypedMerge take configs))
      {
        assertions = [
          {
            assertion = sane-user-cfg == null || num-default-users != 0;
            message = "cannot set `sane.user` without first setting `sane.users.<user>.default = true` for some user";
          }
          {
            assertion = num-default-users <= 1;
            message = "cannot set more than one default user";
          }
        ];
      }
    ];
}
