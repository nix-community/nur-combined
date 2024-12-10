# TODO: move into modules/users.nix
{ config, lib, pkgs, ...}:

let
  # [ ProgramConfig ]
  enabledPrograms = builtins.filter
    (p: p.enabled)
    (builtins.attrValues config.sane.programs);

  # [ ProgramConfig ]
  enabledProgramsWithPackage = builtins.filter (p: p.package != null) enabledPrograms;

  # [ { "<mime-type>" = { prority, desktop } ]
  enabledWeightedMimes = builtins.map weightedMimes enabledPrograms;

  # ProgramConfig -> { "<mime-type>" = { priority, desktop }; }
  weightedMimes = prog: builtins.mapAttrs
    (_key: desktop: {
      priority = prog.mime.priority; desktop = desktop;
    })
    prog.mime.associations;

  # [ { "<mime-type>" = { priority, desktop } ]; } ] -> { "<mime-type>" = [ { priority, desktop } ... ]; }
  mergeMimes = mimes: lib.foldAttrs (item: acc: [item] ++ acc) [] mimes;

  # [ { priority, desktop } ... ] -> Self
  sortOneMimeType = associations: builtins.sort
    (l: r: lib.throwIf
      (l.priority == r.priority)
      "${l.desktop} and ${r.desktop} share a preferred mime type with identical priority ${builtins.toString l.priority} (and so the desired association is ambiguous)"
      (l.priority < r.priority)
    )
    associations;
  sortMimes = mimes: builtins.mapAttrs (_k: sortOneMimeType) mimes;
  # { "<mime-type>"} = [ { priority, desktop } ... ]; } -> { "<mime-type>" = [ "<desktop>" ... ]; }
  removePriorities = mimes: builtins.mapAttrs
    (_k: associations: builtins.map (a: a.desktop) associations)
    mimes;
  # { "<mime-type>" = [ "<desktop>" ... ]; } -> { "<mime-type>" = "<desktop1>;<desktop2>;..."; }
  formatDesktopLists = mimes: builtins.mapAttrs
    (_k: desktops: lib.concatStringsSep ";" desktops)
    mimes;

  mimeappsListPkg = pkgs.writeTextDir "share/applications/mimeapps.list" (
    lib.generators.toINI { } {
      "Default Applications" = formatDesktopLists (removePriorities (sortMimes (mergeMimes enabledWeightedMimes)));
    }
  );

  localShareApplicationsPkg = (pkgs.symlinkJoin {
    name = "user-local-share-applications";
    paths = builtins.map
      (p: builtins.toString p.package)
      (enabledProgramsWithPackage ++ [ { package=mimeappsListPkg; } ]);
  }).overrideAttrs (orig: {
    # like normal symlinkJoin, but don't error if the path doesn't exist.
    # additionally, remove `DBusActivatable=true` from any .desktop files encountered;
    # my dbus session is sandboxed such that it can't activate services even if i thought that was a good idea.
    buildCommand = ''
      mkdir -p $out/share/applications
      for i in $(cat $pathsPath); do
        if [ -e "$i/share/applications" ]; then
          local files=($(cd "$i/share/applications"; ls .))
          for f in "''${files[@]}"; do
            sed '/DBusActivatable=true/d' $i/share/applications/$f > $out/share/applications/$f
          done
        fi
      done
      runHook postBuild
    '';
    postBuild = ''
      # rebuild `mimeinfo.cache`, used by file openers to show the list of *all* apps, not just the user's defaults.
      ${lib.getExe' pkgs.buildPackages.desktop-file-utils "update-desktop-database"} $out/share/applications
    '';
  });

in
{
  # the xdg mime type for a file can be found with:
  # - `xdg-mime query filetype path/to/thing.ext`
  # the default handler for a mime type can be found with:
  # - `xdg-mime query default <mimetype>`  (e.g. x-scheme-handler/http)
  # the nix-configured handler can be found `nix-repl > :lf . > hostConfigs.desko.xdg.mime.defaultApplications`
  #
  # glib/gio is queried via glib.bin output:
  # - `gio mime x-scheme-handler/https`
  # - `gio open <path_or_url>`
  # - `gio launch </path/to/app.desktop>`
  #
  # we can have single associations or a list of associations.
  # there's also options to *remove* [non-default] associations from specific apps
  # N.B.: don't use nixos' `xdg.mime` option becaue that caues `/share/applications` to be linked into the whole system,
  # which limits what i can do around sandboxing. getting the default associations to live in ~/ makes it easier to expose
  # the associations to apps selectively.
  # xdg.mime.enable = true;
  # xdg.mime.defaultApplications = removePriorities (sortMimes (mergeMimes enabledWeightedMimes));

  sane.user.fs.".local/share/applications".symlink.target = "${localShareApplicationsPkg}/share/applications";
}
