{ lib, pkgs, ... }:
let
  logBase = "$HOME/.local/share/s6/logs";
  maybe = cond: value: if cond then value else null;

  # create a derivation whose output is the on-disk representation of some attrset.
  # @path: /foo/bar/...
  # @obj: one of:
  #   - { file = { text = "foo bar"; executable = true|false; } }
  #   - { dir = <obj>; }
  fsItemToDerivation = path: obj: if obj ? dir then
    pkgs.symlinkJoin {
      name = "s6-${path}";
      paths = lib.mapAttrsToList
        (n: v: fsItemToDerivation "${path}/${n}" v)
        obj.dir
      ;
    }
  else if obj ? text then
    if obj.text != null then
      pkgs.writeTextFile {
        name = "s6-${path}";
        destination = path;
        text = obj.text;
      }
    else
      pkgs.emptyDirectory
  else if obj ? executable then
    if obj.executable != null then
      pkgs.writeTextFile {
        name = "s6-${path}";
        destination = path;
        executable = true;
        text = obj.executable;
      }
    else
      pkgs.emptyDirectory
  else throw "don't know how to convert fs item at path ${path} to derivation: ${obj}";

  # call with an AttrSet of fs items:
  # example:
  # ```
  # fsToDerivation {
  #   usr.dir = {
  #     normal.text = "i'm /usr/normal";
  #     exec.executable = ''
  #       #!/bin/sh
  #       echo "i'm executable"
  #     '';
  #     lib.dir = { ... };
  #   };
  #   bin.dir = { ... };
  # }
  fsToDerivation = fs: fsItemToDerivation "/" { dir = fs; };

  # infers the service type from the arguments and creates an attrset usable by `fsToDerivation`.
  # also configures the service for logging, if applicable.
  serviceToFs = { name, check, contents, depends, finish, run }: let
    type = if run != null then "longrun" else "bundle";
    logger = serviceToFs' {
      name = "logger:${name}";
      consumerFor = name;
      run = ''s6-log -- T p'${name}:' "${logBase}/${name}"'';
      type = "longrun";
    };
  in (serviceToFs' {
    inherit name check depends finish run type;
    contents = maybe (type == "bundle") contents;
    producerFor = maybe (type == "longrun") "logger:${name}";
  }) // (lib.optionalAttrs (type == "longrun") logger);

  serviceToFs'= {
    name,
    type,
    check ? null,  #< command to poll to check for service readiness
    consumerFor ? null,
    contents ? null,  #< bundle contents
    depends ? [],
    finish ? null,
    producerFor ? null,
    run ? null,
  }: let
    maybe-notify = lib.optionalString (check != null) "s6-notifyoncheck -n 0 ";
  in {
    "${name}".dir = {
      "type".text = type;
      "contents".text = maybe (contents != null) (
        lib.concatStringsSep "\n" contents
      );
      "consumer-for".text = maybe (consumerFor != null) consumerFor;
      "data".dir = {
        "check".executable = maybe (check != null) ''
          #!/bin/sh
          ${check}
        '';
      };
      # N.B.: if this service is a bundle, then dependencies.d is ignored
      "dependencies.d".dir = lib.genAttrs
        depends
        (dep: { text = ""; })
      ;
      "finish".executable = maybe (finish != null) ''
        #!/bin/sh
        ${finish}
      '';
      "notification-fd".text = maybe (check != null) "3";
      "producer-for".text = maybe (producerFor != null) producerFor;
      "run".executable = maybe (run != null) ''
        #!/bin/sh
        log() {
          printf 's6[%s]: %s\n' '${name}' "$1" | tee /dev/stderr
        }
        log "preparing"

        # s6 is too gentle when i ask it to stop a service,
        # so explicitly kill children on exit.
        # see: <https://stackoverflow.com/a/2173421>
        # before changing this, test that the new version actually kills a service with `s6-rc down <svcname>`
        down() {
          log "trapped on abort signal"
          # "trap -": to avoid recursing
          trap - SIGINT SIGQUIT SIGTERM
          log "killing process group"
          # "kill 0" means kill the current process group (i.e. all descendants)
          kill 0
          exit 0
        }
        trap down SIGINT SIGQUIT SIGTERM

        log "starting"
        # run the service from $HOME by default.
        # particularly, this impacts things like "what directory does my terminal open in".
        # N.B. do not run the notifier from $HOME, else it won't know where to find the `data/check` program.
        # N.B. must be run with `&` + `wait`, else we lose the ability to `trap`.
        ${maybe-notify}env --chdir="$HOME" ${run} <&0 &
        wait
        log "exiting"
      '';
    };
  };

  # create a directory, containing N subdirectories:
  # - svc-a/
  #   - type
  #   - run
  # - svc-b/
  #   - type
  #   - run
  # - ...
  genServices = svcs: fsToDerivation (lib.foldl'
    (acc: srv: acc // (serviceToFs srv))
    {}
    svcs
  );

  # output is a directory containing:
  # - db
  # - lock
  # - n
  # - resolve.cdb
  # - servicedirs/
  #   - svc-a/
  #   - svc-b/
  #   - ...
  #
  # this can then be used by s6-rc-init, like:
  # s6-svscan scandir &
  # s6-rc-init -c $compiled -l $PWD/live -d $PWD/scandir
  # s6-rc -l $PWD/live start svc-a
  #
  # N.B.: it seems the $compiled dir needs to be rw, for s6 to write lock files within it.
  #       so `cp` and `chmod -R 600` it, first.
  compileServices = sources: with pkgs; stdenv.mkDerivation {
    name = "s6-user-services";
    src = sources;
    nativeBuildInputs = [ s6-rc ];
    buildPhase = ''
      s6-rc-compile $out $src
    '';
  };

  # transform the `user.services` attrset into a s6 services list.
  s6SvcsFromConfigServices = services: lib.mapAttrsToList
    (name: service: {
      inherit name;
      check = service.readiness.waitCommand;
      contents = builtins.attrNames (
        lib.filterAttrs (_: cfg: lib.elem name cfg.partOf) services
      );
      depends = service.depends ++ builtins.attrNames (
        lib.filterAttrs (_: cfg: lib.elem name cfg.dependencyOf) services
      );
      finish = service.cleanupCommand;
      run = service.command;
    })
    services
  ;
  # return a list of bundles (AttrSets) which contain this service
  containedBy = services: name: lib.filter (svc: lib.elem name svc.contents) services;
  # for each bundle to which this service belongs, add that bundle's dependencies as direct dependencies of this service.
  # this is to overcome that s6 doesn't support bundles having dependencies.
  pushDownDependencies = services: builtins.map
    (svc: svc // {
      depends = lib.unique (
        svc.depends ++ lib.concatMap
          (bundle: bundle.depends)
          (containedBy services svc.name)
      );
    })
    services
  ;
in
{
  options.sane.users = with lib; mkOption {
    type = types.attrsOf (types.submodule ({ config, ...}: let
      sources = genServices (
        lib.converge pushDownDependencies (
          s6SvcsFromConfigServices config.services
        )
      );
    in {
      # N.B.: `compiled` needs to be writable (for locks -- maybe i can use symlinks to dodge this someday):
      # i populate it to ~/.config as a well-known place, and then copy it to /run before actually using it live.
      fs.".config/s6/compiled".symlink.target = compileServices sources;
      # exposed only for convenience
      fs.".config/s6/sources".symlink.target = sources;

      fs.".profile".symlink.text = ''
        function startS6() {
          local S6_TARGET="''${1:-default}"

          local S6_RUN_DIR="$XDG_RUNTIME_DIR/s6"
          local COMPILED="$S6_RUN_DIR/compiled"
          local LIVE="$S6_RUN_DIR/live"
          local SCANDIR="$S6_RUN_DIR/scandir"

          rm -rf "$SCANDIR"
          mkdir -p "$SCANDIR"
          s6-svscan "$SCANDIR" &
          local SVSCAN=$!

          # the scandir is just links back into the compiled dir,
          # so the compiled dir therefore needs to be writable:
          rm -rf "$COMPILED"
          cp --dereference -R "$HOME/.config/s6/compiled" "$COMPILED"
          chmod -R 0700 "$COMPILED"

          s6-rc-init -c "$COMPILED" -l "$LIVE" -d "$SCANDIR"

          if [ -n "$S6_TARGET" ]; then
            s6-rc -l "$LIVE" start "$S6_TARGET"
          fi

          echo 's6 initialized: Ctrl+C to stop'
          wait "$SVSCAN"
        }
        function startS6WithLogging() {
          # the log dir should already exist by now (nixos persistence); create it just in case something went wrong.
          mkdir -p "${logBase}"
          startS6 2>&1 | tee /dev/stderr | s6-log -- T "${logBase}/catchall"
        }

        primarySessionCommands+=('startS6WithLogging &')
      '';
    }));
  };
}
