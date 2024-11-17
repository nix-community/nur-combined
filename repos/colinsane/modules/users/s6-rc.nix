{ config, lib, pkgs, ... }:
let
  config' = config;
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
  else if obj ? symlink then
    if obj.symlink != null then
      pkgs.runCommandLocal "s6-${path}" { } ''
        mkdir -p "$out/$(dirname "${path}")"
        ln -s "${obj.symlink}" "$out/${path}"
      ''
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

  # infers some service settings from the arguments and creates an attrset usable by `fsToDerivation`.
  # also configures the service for logging, if applicable.
  # type can be:
  # - "longrun"
  # - "bundle"
  # - "oneshot"?
  serviceToFs = { name, check, contents, depends, down, finish, run, up, type }: let
    logger = serviceToFs' {
      name = "logger:${name}";
      consumerFor = name;
      run = ''s6-log -- T p'${name}:' "${logBase}/${name}"'';
      type = "longrun";
    };
  in (serviceToFs' {
    inherit name check depends down finish run type up;
    contents = maybe (type == "bundle") contents;
    # XXX: apparently `oneshot` services can't have loggers: only `longrun` can log.
    producerFor = maybe (type == "longrun") "logger:${name}";
  }) // (lib.optionalAttrs (type == "longrun") logger);

  serviceToFs'= {
    name,
    type,
    check ? null,  #< command to poll to check for service readiness
    consumerFor ? null,
    contents ? null,  #< bundle contents
    depends ? [],
    up ? null,
    finish ? null,
    producerFor ? null,
    run ? null,
    down ? null,
  }: let
    maybe-notify = lib.optionalString (check != null) "s6-notifyoncheck -n 0 ";
    makeAbortable = op: maybe-notify: cli: ''
      #!/bin/sh
      log() {
        printf 's6[%s/%s]: %s\n' '${name}' '${op}' "$1" | tee /dev/stderr
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

      log "handoff"
      # run the service from $HOME by default.
      # particularly, this impacts things like "what directory does my terminal open in".
      # N.B. do not run the notifier from $HOME, else it won't know where to find the `data/check` program.
      # N.B. must be run with `&` + `wait`, else we lose the ability to `trap`.
      ${maybe-notify}env --chdir="$HOME" ${cli} <&0 &
      wait $!
      status=$?
      log "exiting; propagating status: $status"
      exit "$status"
    '';
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
      "run".executable = maybe (run != null) (makeAbortable "run" maybe-notify run);
      # oneshot transitions are stored inline in the database, and so can't use #!/bin/sh so easily
      "down".text = maybe (down != null) down;
      "up".text = maybe (up != null) up;
      # "up".executable = maybe (up != null) (makeAbortable "up" "" up);
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

  # to decrease sandbox escaping, i want to run s6-svscan on a read-only directory
  # so other programs can't edit the service scripts.
  # in practice, that means putting the servicedirs in /nix/store, and linking selective pieces of state
  # towards $XDG_RUNTIME_DIR/s6/live/..., the latter is shared with s6-rc.
  mkScanDir = livedir: compiled: pkgs.runCommandLocal "s6-scandir" { } ''
    cp -R "${compiled}/servicedirs" "$out"
    cd "$out"
    chmod u+w .
    for d in *; do
      chmod u+w "$d"
      ln -s "${livedir}/servicedirs/$d/down" "$d"
      ln -s "${livedir}/servicedirs/$d/event" "$d"
      ln -s "${livedir}/servicedirs/$d/supervise" "$d"
    done
    # these builtin s6-rc services try to create `s` (socket) and `s.lock` inside their directory, when launched.
    # they don't seem to follow symlinks, so patch in a full path.
    # note that other services will try to connect directly to this service's `./s` file, so keeping symlinks around as well is a good idea.
    substituteInPlace "s6rc-fdholder/run" \
      --replace-fail 's6-fdholder-daemon -1 -i data/rules -- s' 's6-fdholder-daemon -1 -i data/rules -- ${livedir}/servicedirs/s6rc-fdholder/s' \
      --replace-fail 's6-ipcclient -l0 -- s' 's6-ipcclient -l0 -- ${livedir}/servicedirs/s6rc-fdholder/s'
    substituteInPlace "s6rc-oneshot-runner/run" \
      --replace-fail 's6-ipcserver-socketbinder -- s' 's6-ipcserver-socketbinder -- ${livedir}/servicedirs/s6rc-oneshot-runner/s' \
      --replace-fail 's6-rc-oneshot-run -l ../.. ' 's6-rc-oneshot-run -l ${livedir} '
    ln -s "${livedir}/servicedirs/s6rc-fdholder/s" s6rc-fdholder/s
    ln -s "${livedir}/servicedirs/s6rc-fdholder/s.lock" s6rc-fdholder/s.lock
    ln -s "${livedir}/servicedirs/s6rc-oneshot-runner/s" s6rc-oneshot-runner/s
    ln -s "${livedir}/servicedirs/s6rc-oneshot-runner/s.lock" s6rc-oneshot-runner/s.lock

    rm -rf .s6-svscan
    ln -s "${livedir}/servicedirs/.s6-svscan" .
  '';

  concatNonNullLines = lines: lib.concatStringsSep "\n" (
    lib.filter (line: line != null) lines
  );

  # transform the `user.services` attrset into a s6 services list.
  s6SvcsFromConfigServices = services: lib.mapAttrsToList
    (name: service: rec {
      inherit name;
      check = service.readiness.waitCommand;
      contents = builtins.attrNames (
        lib.filterAttrs (_: cfg: lib.elem name cfg.partOf) services
      );
      depends = service.depends ++ builtins.attrNames (
        lib.filterAttrs (_: cfg: lib.elem name cfg.dependencyOf) services
      );
      down = maybe (type == "oneshot") service.cleanupCommand;
      finish = maybe (type == "longrun") (concatNonNullLines [
        service.cleanupCommand
        (maybe (service.restartCondition == "on-failure") ''
          if [ "$1" -eq 0 ]; then
            printf "service exited 0: not restarting\n"
            s6-rc stop "$3"
          else
            printf "service exited non-zero: restarting (code: %d)\n" "$1"
          fi
        '')
      ]);
      run = service.command;
      up = service.startCommand;
      type = if service.startCommand != null then
        "oneshot"
      else if service.command != null then
        "longrun"
      else
        "bundle"
      ;
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

  # create a template s6 "live" dir, which can be copied at runtime in $XDG_RUNTIME_DIR/s6/live.
  # this is like a minimal versio of `s6-rc-init`, but tightly coupled to my setup
  # wherein the scandir is external and selectively links back to the livedir
  mkLiveDir = compiled: pkgs.runCommandLocal "s6-livedir" {} ''
    mkdir $out
    touch $out/lock
    touch $out/prefix  # no prefix: empty

    mkdir $out/compiled
    cp ${compiled}/{db,lock,n,resolve.cdb} $out/compiled

    touch $out/state
    mkdir $out/servicedirs
    mkdir $out/servicedirs/.s6-svscan
    for svc in $(ls ${compiled}/servicedirs); do
      # s6-rc-init gives each service one byte of state, initialized to zero. i mimic that here:
      echo -n '\x00' >> $out/state
      mkdir $out/servicedirs/$svc
      # don't auto-start the service when i add the supervisor
      touch $out/servicedirs/$svc/down
      # s6-rc needs to know if the service supports readiness notifications,
      # as this will determine if it waits for it when starting.
      ln -s ${compiled}/servicedirs/$svc/notification-fd $out/servicedirs/$svc/notification-fd
    done
  '';
in
{
  options.sane.users = with lib; mkOption {
    type = types.attrsOf (types.submodule ({ config, name, ...}: let
      sources = genServices (
        lib.converge pushDownDependencies (
          s6SvcsFromConfigServices config.services
        )
      );
      compiled = compileServices sources;
      xdg_runtime_dir = "/run/user/${name}";
      scanDir = mkScanDir "${xdg_runtime_dir}/s6/live" compiled;
      liveDir = mkLiveDir compiled;
    in lib.mkIf (config.serviceManager == "s6") {
      fs.".config/s6/live".symlink.target = liveDir;
      fs.".config/s6/scandir".symlink.target = scanDir;
      fs.".config/s6/compiled".symlink.target = compiled;
      # exposed only for convenience
      fs.".config/s6/sources".symlink.target = sources;

      fs.".profile".symlink.text = ''
        function initS6Dirs() {
          local LIVE="$XDG_RUNTIME_DIR/s6/live"

          mkdir -p "$LIVE"  # create parent dirs
          rm -rf "$LIVE"/*  # remove old state
          # the live dir needs to be read+write. initialize it via the template in ~/.config/s6:
          cp -R "$HOME/.config/s6/live"/* "$LIVE"
          chmod -R 0700 "$LIVE"

          # ensure the log dir, since that'll be needed by every service.
          # the log dir should already exist by now (nixos persistence); create it just in case something went wrong.
          mkdir -p "${logBase}"
        }
        function startS6() {
          local S6_TARGET="''${1-default}"

          local LIVE="$XDG_RUNTIME_DIR/s6/live"

          test -e "$LIVE" || initS6Dirs

          s6-svscan "$(realpath "$HOME/.config/s6/scandir")" &
          local SVSCAN=$!

          # wait for `supervise` processes to appear.
          # this part would normally be done by `s6-rc-init`.
          # maybe there's a more clever way: don't kill `s6-svscan` above, somehow run it on the /nix/store/... path from the very beginning.
          for d in $LIVE/servicedirs/*; do
            while ! s6-svok "$d" ; do
              sleep 0.1
            done
          done

          if [ -n "$S6_TARGET" ]; then
            s6-rc -b -l "$LIVE" start "$S6_TARGET"
          fi

          echo 's6 initialized: Ctrl+C to stop'
          wait "$SVSCAN"
        }
        function startS6WithLogging() {
          mkdir -p "${logBase}"  #< needs to exist for parallel s6-log call
          # disable input echoing, so that user can use framebuffer applications (unl0kr) without keyboard echo characters writing to the same framebuffer
          stty -echo
          startS6 2>&1 | s6-log -- T "${logBase}/catchall"
          # should never be reached
          stty echo
          echo "s6 unexpectedly exited. dropping to shell."
        }

        primarySessionCommands+=('startS6WithLogging')
      '';
    }));
  };
}
