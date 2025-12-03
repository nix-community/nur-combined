{ config, lib, options, pkgs, sane-lib, ... }:
let
  saneCfg = config.sane;
  cfg = config.sane.programs;

  makeSandboxArgs = pkgs.callPackage ./make-sandbox-args.nix { };
  makeSandboxed = pkgs.callPackage ./make-sandboxed.nix { };

  # create a map:
  # {
  #   "${pkgName}" = {
  #     system = true|false;
  #     user = {
  #       "${name}" = true|false;
  #     };
  #   };
  # }
  # for every ${pkgName} in pkgSpecs.
  # `system = true|false` is a computed expression over all the other programs, as evaluated.
  solveDefaultEnableFor = pkgSpecs: lib.foldlAttrs (
    acc: pname: pval: (
      # add "${enableName}".system |= areSuggestionsEnabled pval
      # for each `enableName` in pval.suggestedPrograms.
      # do the same for `user` field.
      lib.foldl (acc': enableName: acc' // {
        "${enableName}" = let
          super = acc'."${enableName}";
        in {
          system = super.system || (pval.enableFor.system && pval.enableSuggested);
          user = super.user // lib.filterAttrs (_u: en: en && pval.enableSuggested) pval.enableFor.user;
        };
      }) acc pval.suggestedPrograms
    )
  ) (mkDefaultEnables pkgSpecs) pkgSpecs;
  mkDefaultEnables = lib.mapAttrs (_pname: _pval: { system = false; user = {}; });
  defaultEnables = solveDefaultEnableFor cfg;

  # wrap a package so that its binaries (maybe) run in a sandbox
  wrapPkg = pkgName: { fs, gsettingsPersist, persist, sandbox, ... }: package: (
    if !sandbox.enable || sandbox.method == null then
      package
    else
      let
        vpn = if sandbox.net == "vpn" then
          let
            firstVpn = lib.findSingle (v: v.isDefault) null null (builtins.attrValues config.sane.vpn);
          in assert firstVpn != config.sane.vpn.wg-home; firstVpn
        else if sandbox.net == "vpn.wg-home" then
          config.sane.vpn.wg-home or null
        else
          null
        ;

        allowedHomePaths = builtins.attrNames fs
          ++ builtins.attrNames persist.byPath
          ++ sandbox.extraHomePaths
          ++ lib.optionals (gsettingsPersist != [] && config.sane.programs.gsettings.enabled) [
            # the actual persistence happens in sane.programs.gsettings
            ".config/glib-2.0/settings"
          ];
          # XXX: don't support dconf persisting until/unless i want to, since the dbus integration is icky
          # ++ lib.optionals (gsettingsPersist != [] && config.sane.programs.dconf.enabled) [
          #   ".config/dconf"
          # ];
        allowedRunPaths = sandbox.extraRuntimePaths;
        allowedPaths = [
          "/nix/store"
          "/bin/sh"

          "/etc"  #< especially for /etc/profiles/per-user/$USER/bin
          "/run/current-system"  #< for basics like `ls`, and all this program's `suggestedPrograms` (/run/current-system/sw/bin)
          # "/run/wrappers"  #< SUID wrappers. they don't mean much inside a namespace.
          # /run/opengl-driver is a symlink into /nix/store; needed by e.g. mpv
          "/run/opengl-driver"
          "/run/opengl-driver-32"  #< XXX: doesn't exist on aarch64?
          "/usr/bin/env"
        ] ++ lib.optionals (sandbox.net == "all" && config.services.resolved.enable) [
          "/run/systemd/resolve"  #< to allow reading /etc/resolv.conf, which ultimately symlinks here (if using systemd-resolved)
        ] ++ lib.optionals (sandbox.net == "all" && config.services.avahi.enable) [
          "/var/run/avahi-daemon"  #< yes, it has to be "/var/run/...". required for nss (e.g. `getent hosts desko.local`)
        ] ++ lib.optionals sandbox.whitelistDbus.system [
          "/var/run/dbus/system_bus_socket"  #< XXX: use /var/run/..., for the rare program which requires that (i.e. avahi users)
        ] ++ sandbox.extraPaths
        ;

        sandboxArgs = makeSandboxArgs {
          inherit (sandbox)
            autodetectCliPaths
            capabilities
            extraConfig
            extraEnv
            keepIpc
            keepPids
            tryKeepUsers
            method
            whitelistPwd
          ;
          netDev = if vpn != null then
            vpn.name
          else
            sandbox.net;
          netGateway = if vpn != null then
            vpn.addrV4
          else
            null;
          dns = if vpn != null then
            vpn.dns
          else
            null;
          allowedDbusCall = lib.flatten (
            lib.mapAttrsToList
              (interface: lib.map (methodSpec: "${interface}=${methodSpec}"))
              sandbox.whitelistDbus.user.call
          );
          allowedDbusOwn = sandbox.whitelistDbus.user.own;
          # the sandboxer knows how to work with duplicated paths, but they're still annoying => `lib.unique`
          allowedPaths = lib.unique allowedPaths;
          allowedHomePaths = lib.unique allowedHomePaths;
          allowedRunPaths = lib.unique allowedRunPaths;
        };
      in
        makeSandboxed {
          inherit pkgName package;
          inherit (sandbox)
            embedSandboxer
            wrapperType
          ;
          extraSandboxerArgs = sandboxArgs;
        }
  );
  pkgSpec = with lib; types.submodule ({ config, name, ... }: {
    options = {
      name = mkOption {
        type = types.str;
        default = name;
        defaultText = lib.literalExpression "name";
      };
      packageUnwrapped = mkOption {
        type = types.nullOr types.package;
        description = ''
          package, or `null` if the program is some sort of meta set (in which case it much EXPLICITLY be set null).
        '';
        default =
          let
            pkgPath = lib.splitString "." name;
          in
            # package can be inferred by the attr name, allowing shorthand like
            #   `sane.programs.nano.enable = true;`
            # this indexing will throw if the package doesn't exist and the user forgets to specify
            # a valid source explicitly.
            lib.getAttrFromPath pkgPath pkgs;
        defaultText = lib.literalExpression ''pkgs.''${lib.splitString "." name}'';
      };
      package = mkOption {
        type = types.nullOr types.package;
        description = ''
          assigned internally.
          this is `packageUnwrapped`, but with the binaries possibly wrapped in sandboxing measures.
        '';
      };
      enableFor.system = mkOption {
        type = types.bool;
        description = ''
          place this program on the system PATH
        '';
      };
      enableFor.user = mkOption {
        type = types.attrsOf types.bool;
        description = ''
          place this program on the PATH for some specified user(s).
        '';
      };
      enabled = mkOption {
        type = types.bool;
        description = ''
          generated (i.e. read-only) value indicating if the program is enabled either for any user or for the system.
        '';
      };
      suggestedPrograms = mkOption {
        type = types.listOf types.str;
        default = [];
        description = ''
          list of other programs a user may want to enable alongside this one.
          for example, the gnome desktop environment would suggest things like its settings app.
        '';
      };
      enableSuggested = mkOption {
        type = types.bool;
        default = true;
      };
      # XXX: even if these `gsettings` and `mime` properties aren't used by this module,
      # putting them here allows for the visibility by the consumers that do actually use them.
      gsettings = mkOption {
        type = types.attrs;
        default = {};
        description = ''
          gsetting config values to provide this program (and the broader system).
          this is the nix representation of what you'd want `dconf dump /` to show
          (only, it's not plumbed to dconf but rather the layer above it -- gsettings).

          this is typically set by:
          1. run a program, unsandboxed.
          2. modify a setting inside the program's UI.
          3. grep `~/.config/glib-2.0/settings/keyfile` to find what it set.
          4. add the settings you care about to the program's nix `gsettings`.
        '';
        example = ''
        {
          "org/erikreider/swaync" = {
            dnd-state = true;
          };
        }
        '';
      };
      gsettingsPersist = mkOption {
        type = types.listOf types.str;
        default = [];
        description = ''
          list of groups which this program is allowed to persist.
        '';
        example = [
          "org/gnome/clocks"
        ];
      };
      mime.priority = mkOption {
        type = types.int;
        default = 100;
        description = ''
          program with the numerically lower priority takes precedence whenever two mime associations overlap.
        '';
      };
      mime.associations = mkOption {
        type = types.attrsOf types.str;
        default = {};
        description = ''
          mime associations. each entry takes the form of:
            "<mime type>" = "<launcher>.desktop"
          e.g.
          {
            "audio/flac" = "vlc.desktop";
            "application/pdf" = "org.gnome.Evince.desktop";
          }
        '';
      };
      mime.urlAssociations = mkOption {
        # TODO: it'd be cool to have the value part of this be `.desktop` files.
        # mimeo doesn't quite do that well. would need a wrapper script which does `mimeo --desk2field Exec mpv.desktop` to get the command
        # and then interpolate the paths into it (%U)
        type = types.attrsOf types.str;
        default = {};
        description = ''
          map of regex -> command.
          e.g. "^https?://(www.)?youtube.com/watch\?.*v=" = "mpv %U"
        '';
      };
      persist = mkOption {
        type = options.sane.persist.sys.type;
        default = {};
        description = ''
          entries to pass onto `sane.persist.sys` or `sane.user.persist`
          when this program is enabled.
        '';
      };
      fs = mkOption {
        # funny type to allow deferring the option merging down to the layer below
        type = types.attrsOf (types.coercedTo types.attrs (a: [ a ]) (types.listOf types.attrs));
        default = {};
        description = "files to populate when this program is enabled";
      };
      secrets = mkOption {
        type = types.attrsOf types.path;
        default = {};
        description = ''
          fs paths to link to some decrypted secret.
          the secret will have same owner as the user under which the program is enabled.
        '';
      };
      env = mkOption {
        type = types.attrsOf types.str;
        default = {};
        description = ''
          environment variables to set when this program is enabled.
          env vars set here are intended to propagate everywhere into the user's (or system's) session/services;
          they aren't visible just to the program which specified them.
        '';
      };
      services = mkOption {
        type = options.sane.user._options.services.type;
        default = {};
        description = ''
          user services to define if this package is enabled.
          acts as noop for root-enabled packages.
          see `sane.users.<user>.services` for options;
        '';
        # TODO: this `apply` should by moved to where we pass the `services` down to `sane.users`
        # XXX: we could, for every `suggestedPrograms`, make the services depend on all that other program's services
        apply = lib.mapAttrs (svcName: svcCfg:
          svcCfg // lib.optionalAttrs (builtins.tryEval svcCfg.description).success {
            # ensure service dependencies based on what a service's program whitelists.
            # only do this for the services which are *defined* by this program though (i.e. `scvCfg ? description`)
            # so as to avoid idioms like when sway adds `graphical-session.partOf = default`
            depends = svcCfg.depends
              ++ lib.optionals (((config.persist.byStore or {}).private or []) != []) [
              "private-storage"
            ] ++ lib.optionals (svcName != "dbus-user" && config.sandbox.whitelistDbus.user != {} && cfg.dbus.enabled) [
              "dbus-user"
            ] ++ lib.optionals ((!builtins.elem "wayland" svcCfg.partOf) && config.sandbox.whitelistWayland) [
              "wayland"
            ] ++ lib.optionals ((!builtins.elem "x11" svcCfg.partOf) && config.sandbox.whitelistX) [
              "x11"
            ] ++ lib.optionals ((!builtins.elem "sound" svcCfg.partOf) && config.sandbox.whitelistAudio) [
              "sound"
            ] ++ lib.optionals (builtins.elem "gnome-keyring" config.suggestedPrograms) [
              "gnome-keyring"
            ] ++ lib.optionals config.sandbox.whitelistSsh [
              "ssh-agent"
            ];
          }
        );
      };
      buildCost = mkOption {
        type = types.enum [ 0 1 2 3 ];
        default = 0;
        description = ''
          whether this package is very slow, or has unique dependencies which are very slow to build.
          marking packages like this can be used to achieve faster, but limited, rebuilds/deploys (by omitting the package).
          - 0: this package is necessary for baseline usability
          - 1: this package is a nice-to-have, and not too costly to build
          - 2: this package is a nice-to-have, but costly to build (e.g. `libreoffice`, some webkitgtk-based things)
          - 3: this package is costly to build, and could go without (some lesser-used webkitgtk-based things)
        '';
      };
      sandbox.net = mkOption {
        type = types.coercedTo
          types.str
          (s: if s == "clearnet" || s == "localhost" then "all" else s)
          (types.enum [ null "all" "vpn" "vpn.wg-home" ]);
        default = null;
        description = ''
          how this app should have its network traffic routed.
          - "all": unsandboxed network.
          - "clearnet": traffic is routed only over clearnet.
            currently, just an alias for "all".
          - "localhost": only needs access to other services running on this host.
            currently, just an alias for "all".
          - "vpn": to route all traffic over the default VPN.
          - "vpn.wg-home": to route all traffic over the wg-home VPN.
          - null: to maximally isolate from the network.
        '';
      };
      sandbox.method = mkOption {
        type = types.nullOr (types.enum [ "bunpen" ]);
        default = "bunpen";
        description = ''
          how/whether to sandbox all binaries in the package.
        '';
      };
      sandbox.enable = mkOption {
        type = types.bool;
        default = saneCfg.sandbox.enable;
        apply = value: saneCfg.sandbox.enable && value;
      };
      sandbox.embedSandboxer = mkOption {
        type = types.bool;
        default = false;
        description = ''
          whether the sandboxed application should reference its sandboxer by path or by name.
        '';
      };
      sandbox.wrapperType = mkOption {
        type = types.enum [ "inplace" "wrappedDerivation" ];
        default = "wrappedDerivation";
        description = ''
          how to manipulate the `packageUnwrapped` derivation in order to achieve sandboxing.
          - inplace: applies an override to `packageUnwrapped`, so that all `bin/` files are sandboxed,
                     and call into un-sandboxed dot-files within `bin/` (like makeWrapper does).
          - wrappedDerivation: leaves the input derivation unchanged, and creates a _new_ derivation whose
                               binaries wrap the binaries in the original derivation with a sandbox.

          "inplace" is more reliable, but "wrappedDerivation" is more lightweight (doesn't force any rebuilds).
          the biggest gap in "wrappedDerivation" is that it doesn't link anything outside `bin/`, except for
          some limited (verified safe) support for `share/applications/*.desktop`
        '';
      };
      sandbox.autodetectCliPaths = mkOption {
        type = types.coercedTo types.bool
          (b: if b then "existing" else null)
          (types.nullOr (types.enum [
            "existing"
            "existingDir"
            "existingDirOrParent"
            "existingFile"
            "existingFileOrParent"
            "existingOrParent"
            "parent"
          ]));
        default = null;
        description = ''
          if a CLI argument looks like a PATH, should we add it to the sandbox?
          - null => never
          - "existing" => only if the path exists.
          - "existingFile" => only if the path exists *and is file-like* (i.e. a file or a symlink to a file, but not a directory)
          - "parent" => allow access to the directory containing any file (whether that file exists or not). useful for certain media viewers/library managers.
          - "existingOrParent" => add the path if it exists; if not, add its parent if that exists. useful for programs which create files or directories.
          - "existingFileOrParent" => add the path if it exists and is file-like; if not, add its parent if that exists. useful for programs which create files.
        '';
      };
      sandbox.capabilities = mkOption {
        type = types.listOf types.str;
        default = [];
        description = ''
          list of Linux capabilities the program needs. lowercase, and without the cap_ prefix.
          e.g. sandbox.capabilities = [ "net_admin" "net_raw" ];
        '';
      };
      sandbox.keepIpc = mkOption {
        type = types.bool;
        default = false;
        description = ''
          if `false`, then the process is placed in a new IPC namespace, if the sandboxer supports that.
        '';
      };
      sandbox.keepPids = mkOption {
        type = types.bool;
        default = false;
        description = ''
          if `false`, then the process is placed in a new PID namespace, if the sandboxer supports that.
        '';
      };
      sandbox.keepPidsAndProc = mkOption {
        type = types.bool;
        default = false;
        description = ''
          if `true`, then the process keeps its pid namespace (`keepPids`) AND retains access to all of /proc.
          this is usually wanted above just `keepPids`: it's rare to want to keep your pidspace but not access /proc.
        '';
      };
      sandbox.tryKeepUsers = mkOption {
        type = types.bool;
        default = false;
        description = ''
          for namespace-based sandboxing, a new user namespace is required in order to create
          the other namespaces (i.e. mount namespace, net namespace, and so on).
          if set to `false`, then the sandboxer will *attempt* to create these namespaces *without*
          first creating a new user namespace. this requires CAP_SYS_ADMIN. if invoked without
          such capabilities, the process will still be placed in a new user namespace.

          setting this `false` is desirable in a few circumstances:
          1. the sandboxed program wants some subset of super-user capabilities.
          2. the sandboxed program wants to know the identity of other users (e.g. accurate `ls` info).
        '';
      };
      sandbox.whitelistAudio = mkOption {
        type = types.bool;
        default = false;
        description = ''
          allow sandbox to freely interact with pulse/pipewire.
        '';
      };
      sandbox.whitelistAvDev = mkOption {
        type = types.bool;
        default = false;
        description = ''
          allow sandbox to freely interact with raw audio/video devices under /dev,
          e.g. /dev/video0, /dev/snd, /dev/v4l/...
          pipewire-aware applications shouldn't need this.
        '';
      };
      sandbox.whitelistDbus.user = mkOption {
        type = types.coercedTo
          types.bool (b: { all = b; })
          (types.submodule {
            options = {
              all = mkOption {
                type = types.bool;
                default = false;
                description = ''
                  allow full, unrestricted dbus access
                '';
              };
              own = mkOption {
                type = types.listOf types.str;
                default = [];
                description = ''
                  allow the sandbox to own any well-known name in this list.
                '';
              };
              call = mkOption {
                type = types.attrsOf (types.coercedTo types.str (s: [ s ] ) (types.listOf types.str));
                default = {};
                description = ''
                  for each attribute name, allow the sandbox to call methods on that well-known bus name
                  so long as they satisfy the specifier encoded in the attribute value.

                  e.g. { "org.freedesktop.portal" = [ "org.freedesktop.portal.FileChooser.*"; ]; };
                '';
              };
            };
          })
        ;
        default = {};
        description = ''
          allow sandbox to selectively interact with user dbus services.
          e.g. {
            own = [ "org.gnome.Calls" ];
            call."org.freedesktop.portal" = "org.freedesktop.portal.FileChooser.*";
          };
          special `*` path can be used to allow ALL user dbus traffic:
          e.g. {
            "*".call = true;
            "*".own = true;
          }
        '';
      };
      sandbox.whitelistDbus.system = mkOption {
        type = types.bool;
        default = false;
        description = ''
          allow sandbox to freely interact with system dbus services.
        '';
      };
      sandbox.whitelistDri = mkOption {
        type = types.bool;
        default = false;
        description = ''
          allow sandbox to access the kernel's /dev/dri interface(s).
          this enables GPU acceleration, particularly for mesa applications,
          however, this basically amounts to letting the sandbox send GPU-specific
          commands directly to the GPU (or, its kernel module), which is a rather
          broad and unaudited attack surface.
        '';
      };
      sandbox.whitelistMpris.controlPlayers = mkOption {
        type = types.bool;
        default = false;
        description = ''
          allow to control *all known* mpris-capable players on the machine.
        '';
      };
      sandbox.whitelistPortal = mkOption {
        type = types.listOf (types.enum [
          # portal references: <https://flatpak.github.io/xdg-desktop-portal/docs/api-reference.html>
          # "Account"
          "Camera"
          # "Clipboard"  # XXX(2025-01-08): inaccessible due to missing org.freedesktop.impl.portal.Clipboard
          # "Device"  # removed in 1.19.0 (2024-10-09)
          "DynamicLauncher"
          # "Email"
          "FileChooser"
          # "FileTransfer" # XXX(2025-01-08): inaccessible. part of org.freedesktop.portal.Documents, which i'm not using
          # "GameMode"
          # "Inhibit" # XXX(2025-01-08): inaccessible due to missing org.freedesktop.impl.portal.Inhibit
          "Location"
          # "MemoryMonitor"
          "NetworkMonitor"  # bleh!
          "Notification"
          "OpenURI"
          # "PowerProfileMonitor"
          "Print"
          "ProxyResolver"
          # "Realtime"
          "ScreenCast"
          "Screenshot"
          # "Settings"
          # "Trash"
          # "Usb"  # added in 1.19.1 (2024-12-21)
          # "Wallpaper"
        ]);
        default = [];
        description = ''
          allow calling specific interfaces under org.freedesktop.portal
        '';
      };
      sandbox.whitelistPwd = mkOption {
        type = types.bool;
        default = false;
        description = ''
          allow the program full access to whichever directory it was launched from.
        '';
      };
      sandbox.whitelistS6 = mkOption {
        type = types.bool;
        default = false;
        description = ''
          allow the program to start/stop s6 services.
        '';
      };
      sandbox.whitelistSecurityKeys = mkOption {
        type = types.bool;
        default = false;
        description = ''
          allow sandbox to freely interact with hardware security keys, like Yubikeys.
          it would seem the protocol for interacting with these is fairly ad-hoc, and based upon USB HID.
          so generally this option over-exposes, and grants the sandbox access to *all* USB HID devices.
        '';
      };
      sandbox.whitelistSendNotifications = mkOption {
        type = types.bool;
        default = false;
        description = ''
          allow the program to send notifications to the desktop manager (like `notify-send`).
          typically works via dbus.
        '';
      };
      sandbox.whitelistSsh = mkOption {
        type = types.bool;
        default = false;
        description = ''
          allow the program to communicate with ssh-agent.
        '';
      };
      sandbox.whitelistSystemctl = mkOption {
        type = types.bool;
        default = false;
        description = ''
          allow the program to start/stop systemd system services.
        '';
      };
      sandbox.whitelistWayland = mkOption {
        type = types.bool;
        default = false;
        description = ''
          allow sandbox to communicate with the wayland server.
          note that this does NOT permit access to compositor admin tooling like `swaymsg`.
        '';
      };
      sandbox.whitelistX = mkOption {
        type = types.bool;
        default = false;
        description = ''
          allow the sandbox to communicate with the X server.
          typically, this is actually the Xwayland server and you should also enable `whitelistWayland`.
        '';
      };

      sandbox.extraPaths = mkOption {
        type = types.listOf types.str;
        default = [];
        description = ''
          additional absolute paths to bind into the sandbox.
        '';
      };
      sandbox.extraHomePaths = mkOption {
        type = types.listOf types.str;
        default = [];
        description = ''
          additional home-relative paths to bind into the sandbox.
        '';
      };
      sandbox.extraRuntimePaths = mkOption {
        type = types.listOf types.str;
        default = [];
        description = ''
          additional $XDG_RUNTIME_DIR-relative paths to bind into the sandbox.
          e.g. `[ "bus" "wayland-1" ]` to bind the dbus and wayland sockets.
          or `[ "/" ]` to bind all of XDG_RUNTIME_DIR.
        '';
      };

      sandbox.extraEnv = mkOption {
        type = types.attrsOf types.str;
        default = {};
        description = ''
          extra environment variables which should be set when running the program in a sandboxed fashion.
          certain expressions are expanded when evaluating the environment, such as:
          - `$HOME`
          - `$XDG_RUNTIME_DIR`
          escape expansion with `$$`
        '';
      };
      sandbox.matplotlibCacheDir = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          place the matplotlib cache in a custom directory.
          this massively improves launch times for any matplotlib application that loads fonts,
          indicated by the stdout output: "Matplotlib is building the font cache; this may take a moment."
        '';
      };
      sandbox.mesaCacheDir = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          place the mesa cache in a custom directory.
          generally, most GUI applications should have their mesa cache directory
          persisted to disk to (1) reduce ram consumption and (2) massively improve loading speed.
          mesa will create its *own* directory under here.

          to locate empty mesa shader cache dirs (and identify apps that aren't using it):
          - `fd mesa ~/.cache | xargs -n 1 sh -c 'test -d $1/mesa_shader_cache_db || echo $1' -- | sort`
        '';
      };
      sandbox.tmpDir = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          configure TMPDIR to some home-relative path when running the program.
          useful if the program uses so much tmp space that you'd prefer to back it by disk instead of force it to stay in RAM.
        '';
      };

      sandbox.extraConfig = mkOption {
        type = types.listOf types.str;
        default = [];
        description = ''
          extra arguments to pass to the sandbox wrapper.
          example: [
            "--bunpen-keep-pid"
          ]
        '';
      };
      configOption = mkOption {
        type = types.raw;
        default = mkOption {
          type = types.submodule {};
          default = {};
        };
        description = ''
          declare any other options the program may be configured with.
          you probably want this to be a submodule.
          the option *definitions* can be set with `sane.programs."foo".config = ...`.
        '';
      };
      config = config.configOption;
    };

    config = let
      enabledForUser = builtins.any (en: en) (lib.attrValues config.enableFor.user);
      passesSlowTest = config.buildCost <= saneCfg.maxBuildCost;
      mkWeakDefault = lib.mkOverride 2000; #< even weaker than `mkDefault`
    in {
      enableFor.system = mkWeakDefault defaultEnables."${name}".system;
      enableFor.user = mkWeakDefault defaultEnables."${name}".user;
      enabled = (config.enableFor.system || enabledForUser) && passesSlowTest;
      package = if config.packageUnwrapped == null then
        null
      else
        wrapPkg name config config.packageUnwrapped
      ;
      suggestedPrograms = lib.mkIf saneCfg.sandbox.enable (
        lib.optionals (config.sandbox.method == "bunpen") [
          "bunpen"
        ]
      );
      # declare a fs dependency for each secret, but don't specify how to populate it yet.
      #   can't populate it here because it varies per-user.
      # this gets the symlink into the sandbox, but not the actual secret.
      fs = lib.mapAttrs (_homePath: _secretSrc: {}) config.secrets;

      sandbox.keepPids = lib.mkIf config.sandbox.keepPidsAndProc true;

      sandbox.whitelistDbus.system = lib.mkIf config.sandbox.whitelistSystemctl true;

      sandbox.whitelistDbus.user.call = lib.mkMerge ([
        (lib.mkIf config.sandbox.whitelistSendNotifications {
          "org.freedesktop.Notifications" = "*";  # Notify, NotificationClosed, NotificationReplied, ActionInvoked
          "org.erikreider.swaync.cc" = "*";  #< probably overkill
        })
        (lib.mkIf config.sandbox.whitelistMpris.controlPlayers {
          # "org.mpris.MediaPlayer2.playerctld" = "*";
          # `org.mpris.MediaPlayer2.*` acts recursively, granting access to e.g.:
          # - org.mpris.MediaPlayer2.mpv  (which mpv claims by default)
          # - org.mpris.MediaPlayer2.mpv.instance2  (which mpv claims when the former is already taken)
          "org.mpris.MediaPlayer2.*" = "*";  #< TODO: limit to only being able to call actual interface members, otherise this may inadvertently grant access to other dbus controls of the player (which could be large, e.g. a IM client or web browser)
        })
      ] ++ lib.forEach config.sandbox.whitelistPortal (p: {
        "org.freedesktop.portal.Desktop" = [
          "org.freedesktop.portal.${p}.*"
          # "org.freedesktop.DBus.Peer"  #< seems to not be needed
          # "org.freedesktop.DBus.Properties"
          "org.freedesktop.DBus.Introspectable.Introspect"  #< REQUIRED, for e.g. `sane-open`
        ];
      }));

      sandbox.whitelistPortal = lib.mkIf config.sandbox.whitelistSendNotifications [ "Notification" ];

      sandbox.extraEnv = {
        MESA_SHADER_CACHE_DIR = lib.mkIf (config.sandbox.mesaCacheDir != null) "$HOME/${config.sandbox.mesaCacheDir}";
        MPLCONFIGDIR = lib.mkIf (config.sandbox.matplotlibCacheDir != null) "$HOME/${config.sandbox.matplotlibCacheDir}";
        TMPDIR = lib.mkIf (config.sandbox.tmpDir != null) "$HOME/${config.sandbox.tmpDir}";
      };

      sandbox.extraPaths =
        lib.optionals config.sandbox.whitelistDri [
          # /dev/dri/renderD128: requested by wayland-egl (e.g. KOreader, animatch, geary)
          # - but everything seems to gracefully fallback to *something* (MESA software rendering?)
          #   - CPU usage difference between playing videos in Gtk apps (e.g. fractal) with v.s. without DRI is 10% v.s. 90%.
          # - GPU attack surface is *large*: <https://security.stackexchange.com/questions/182501/modern-linux-gpu-driver-security>
          "/dev/dri" "/sys/dev/char" "/sys/devices" # (lappy: "/sys/devices/pci0000:00", moby needs something different)
        ]
        ++ lib.optionals config.sandbox.whitelistX [ "/tmp/.X11-unix" ]
        ++ lib.optionals config.sandbox.keepPidsAndProc [ "/proc" ]
        ++ lib.optionals config.sandbox.whitelistAvDev [
          # the number of /dev/{media,v4l-subdev,video} devices varies based on device,
          # and can even change as the kernel drivers are improved.
          # enable way more here than any of my devices actually require, for the sake of not being fragile.
          "/dev/media0"
          "/dev/media1"
          "/dev/media2"
          "/dev/media3"
          "/dev/media4"
          "/dev/media5"
          "/dev/media6"
          "/dev/media7"
          "/dev/media8"
          "/dev/media9"
          "/dev/snd"
          "/dev/v4l"
          "/dev/v4l-subdev0"
          "/dev/v4l-subdev1"
          "/dev/v4l-subdev2"
          "/dev/v4l-subdev3"
          "/dev/v4l-subdev4"
          "/dev/v4l-subdev5"
          "/dev/v4l-subdev6"
          "/dev/v4l-subdev7"
          "/dev/v4l-subdev8"
          "/dev/v4l-subdev9"
          "/dev/v4l-subdev10"
          "/dev/v4l-subdev11"
          "/dev/v4l-subdev12"
          "/dev/v4l-subdev13"
          "/dev/v4l-subdev14"
          "/dev/v4l-subdev15"
          "/dev/v4l-subdev16"
          "/dev/v4l-subdev17"
          "/dev/v4l-subdev18"
          "/dev/v4l-subdev19"
          # /dev/videoN is used for webcam on lappy, and camera on moby
          "/dev/video0"
          "/dev/video1"
          "/dev/video2"
          "/dev/video3"
          "/dev/video4"
          "/dev/video5"
          "/dev/video6"
          "/dev/video7"
          "/dev/video8"
          "/dev/video9"
          "/dev/video10"
          "/dev/video11"
          "/dev/video12"
          "/dev/video13"
          "/dev/video14"
          "/dev/video15"
          "/dev/video16"
          "/dev/video17"
          "/dev/video18"
          "/dev/video19"

          # specifically for pipewire + wireplumber (for cameras on moby, they seem to both need these identical paths)
          "/run/udev"
          "/sys/bus/media"  #< for moby camera
          "/sys/class/sound"
          "/sys/class/video4linux"  #< for lappy camera
          "/sys/dev/char"  #< for moby camera
          "/sys/devices"
          "/sys/firmware"  #< for moby camera, to parse its devicetree
          # "/dev"
        ] ++ lib.optionals config.sandbox.whitelistSecurityKeys [
          "/dev/hidraw0"
          "/dev/hidraw1"
          "/dev/hidraw2"
          "/dev/hidraw3"
          "/dev/hidraw4"
          "/dev/hidraw5"
          "/dev/hidraw6"
          "/dev/hidraw7"
          "/dev/hidraw8"
          "/dev/hidraw9"
          "/dev/hidraw10"
          "/dev/hidraw11"
          "/dev/hidraw12"
          "/dev/hidraw13"
          "/dev/hidraw14"
          "/dev/hidraw15"
          "/dev/hidraw16"
          "/dev/hidraw17"
          "/dev/hidraw18"
          "/dev/hidraw19"
          "/dev/hidraw20"
          "/dev/hidraw21"
          "/dev/hidraw22"
          "/dev/hidraw23"
          "/dev/hidraw24"
          "/dev/hidraw25"
          "/dev/hidraw26"
          "/dev/hidraw27"
          "/dev/hidraw28"
          "/dev/hidraw29"
          "/sys/class/hidraw"
        ] ++ lib.optionals config.sandbox.whitelistSystemctl [
          "/run/systemd/system"  # TODO(2025-01-20): still necessary?
          "/run/systemd/private"
        ]
      ;
      sandbox.extraRuntimePaths =
        lib.optionals config.sandbox.whitelistAudio [ "pipewire" "pulse" ]  # this includes pipewire/pipewire-0-manager: is that ok?
        ++ lib.optionals config.sandbox.whitelistDbus.user.all [ "dbus" ]
        ++ lib.optionals config.sandbox.whitelistWayland [ "wl" ]  # app can still communicate with wayland server w/o this, if it has net access
        ++ lib.optionals config.sandbox.whitelistS6 [ "s6" ]  # TODO: this allows re-writing the services themselves: don't allow that!
        ++ lib.optionals config.sandbox.whitelistSsh [ "ssh-agent" ]
      ;
      sandbox.extraHomePaths = let
        whitelistDir = dir: lib.optionals (lib.any (p: lib.hasPrefix "${dir}/" p) (builtins.attrNames config.fs)) [
          dir
        ];
        mainProgram = (config.packageUnwrapped.meta or {}).mainProgram or null;
      in
        # assume the program is free to access any files in ~/.config/<name>, ~/.local/share/<name> -- if those exist.
        # the benefit of this is that the program will see updates to its files made *outside* of the sandbox,
        # allowing e.g. manual modification of ~/.config/FOO/thing.json to be seen by the program.
        whitelistDir ".config/${name}"
        ++ whitelistDir ".local/share/${name}"
        # some packages, e.g. swaynotificationcenter, store the config under the binary name instead of the package name
        ++ lib.optionals (mainProgram != null) (whitelistDir ".config/${mainProgram}")
        ++ lib.optionals (mainProgram != null) (whitelistDir ".local/share/${mainProgram}")
        ++ lib.optionals (config.sandbox.mesaCacheDir != null) [
          config.sandbox.mesaCacheDir
        ] ++ lib.optionals (config.sandbox.matplotlibCacheDir != null) [
          config.sandbox.matplotlibCacheDir
        ] ++ lib.optionals (config.sandbox.tmpDir != null) [
          config.sandbox.tmpDir
        ]
      ;
    };
  });
  toPkgSpec = with lib; types.coercedTo types.package (p: { package = p; }) pkgSpec;

  configs = lib.mapAttrsToList (name: p: {
    assertions = [
      {
        assertion = !(p.sandbox.enable && p.sandbox.method == null) || !p.enabled || p.package == null || config.sane.sandbox.strict != "assert";
        message = "program ${name} specified no `sandbox.method`; please configure a method, or set sandbox.enable = false.";
      }
      {
        assertion = p.sandbox.net == "all" || p.sandbox.method != null || !p.enabled || p.package == null || config.sane.sandbox.strict != "assert";
        message = ''program "${name}" requests net "${builtins.toString p.sandbox.net}", which requires sandboxing, but sandboxing wasn't configured'';
      }
    ] ++ builtins.map (sug: {
      assertion = cfg ? "${sug}";
      message = ''program "${sug}" referenced by "${name}", but not defined'';
    }) p.suggestedPrograms;

    warnings = lib.mkIf (config.sane.sandbox.strict == "warn" && p.sandbox.enable && p.sandbox.method == null && p.enabled && p.package != null) [
      "program ${name} specified no `sandbox.method`; please configure a method, or set sandbox.enable = false."
    ];

    system.checks = lib.mkIf (p.enabled && p.sandbox.enable && p.sandbox.method != null && p.package != null) [
      p.package.passthru.checkSandboxed
    ];

    # conditionally add to system PATH and env
    environment = lib.optionalAttrs (p.enabled && p.enableFor.system) {
      systemPackages = lib.mkIf (p.package != null) [ p.package ];
      # sessionVariables are set by PAM, as opposed to environment.variables which goes in /etc/profile
      sessionVariables = lib.mapAttrs (k: v: lib.mkOverride p.mime.priority v) p.env;
    };

    # conditionally add to user(s) PATH
    users.users = lib.mapAttrs (userName: en: {
      packages = lib.mkIf (p.package != null && en && p.enabled) [ p.package ];
    }) p.enableFor.user;

    # conditionally persist relevant user dirs and create files
    sane.users = lib.mapAttrs (user: en: lib.mkIf (en && p.enabled) {
      inherit (p) services;
      environment = lib.mapAttrs (k: v: lib.mkOverride p.mime.priority v) p.env;
      fs = lib.mkMerge [
        p.fs
        # link every secret into the fs:

        (lib.mapAttrs
          # TODO: use the user's *actual* home directory, don't guess.
          (homePath: _src: { symlink.target = "/run/secrets/home/${user}/${homePath}"; })
          p.secrets
        )
        # alternative double indirection which may be slightly friendlier to sandboxing:
        #   ~/.config/FOO.secret => ~/.config/secrets/.config/FOO.secret => /run/secrets/home/${user}/.config/FOO.secret
        # whereas /run/secrets/* is unreadable *except* for the leafs, ~/.config/secrets is readable and traversable by $USER.
        # (lib.mapAttrs
        #   # TODO: use the user's *actual* home directory, don't guess.
        #   (homePath: _src: sane-lib.fs.wantedSymlinkTo "/home/${user}/.config/secrets/${homePath}")
        #   p.secrets
        # )
        # (lib.mapAttrs'
        #   (homePath: _src: {
        #     name = ".config/secrets/${homePath}";
        #     value = sane-lib.fs.wantedSymlinkTo "/run/secrets/home/${user}/${homePath}";
        #   })
        #   p.secrets
        # )
      ];
      persist = lib.mkMerge [
        p.persist
        (lib.optionalAttrs (p.sandbox.matplotlibCacheDir != null) {
          # persist the matplotlib cache to private storage by default;
          # but allow the user to override that.
          byPath."${p.sandbox.matplotlibCacheDir}".store = lib.mkDefault "private";
        })
        (lib.optionalAttrs (p.sandbox.mesaCacheDir != null) {
          # persist the mesa cache to private storage by default;
          # but allow the user to override that.
          byPath."${p.sandbox.mesaCacheDir}".store = lib.mkDefault "private";
        })
        (lib.optionalAttrs (p.sandbox.tmpDir != null) {
          byPath."${p.sandbox.tmpDir}".store = lib.mkDefault "ephemeral";
        })
      ];
    }) p.enableFor.user;

    # make secrets available for each user
    sops.secrets = lib.concatMapAttrs
      (user: en: lib.mkIf (en && p.enabled) (
        lib.mapAttrs'
          (homePath: src: {
            # TODO: use the user's *actual* home directory, don't guess.
            # XXX: name CAN'T START WITH '/', else sops creates the directories funny.
            # TODO: report this upstream.
            name = "home/${user}/${homePath}";
            value = {
              owner = user;
              sopsFile = src;
              format = "binary";
            };
          })
          p.secrets
      ))
      p.enableFor.user;

  }) cfg;
in
{
  options = with lib; {
    # TODO: consolidate these options under one umbrella attrset
    sane.programs = mkOption {
      type = types.attrsOf toPkgSpec;
      default = {};
    };
    sane.maxBuildCost = mkOption {
      type = types.enum [ 0 1 2 3 ];
      default = 3;
      description = ''
        max build cost of programs to ship.
        set to 0 to get the fastest, but most restrictive build.
      '';
    };
    sane.sandbox.strict = mkOption {
      type = types.enum [ false "warn" "assert" ];
      default = "warn";
      description = ''
        whether to require that every `sane.program` explicitly specify its sandbox settings.
      '';
    };
    sane.sandbox.enable = mkOption {
      type = types.bool;
      default = true;
      description = ''
        whether to sandbox any programs at all
      '';
    };
  };

  config =
    let
      take = f: {
        assertions = f.assertions;
        environment.systemPackages = f.environment.systemPackages;
        environment.sessionVariables = f.environment.sessionVariables;
        users.users = f.users.users;
        sane.users = f.sane.users;
        sops.secrets = f.sops.secrets;
        system.checks = f.system.checks;
        warnings = f.warnings;
      };
    in lib.mkMerge [
      (take (sane-lib.mkTypedMerge take configs))
      {
        # expose the pkgs -- as available to the system -- as a build target.
        system.build.pkgs = pkgs;
      }
    ];
}
