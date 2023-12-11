{ config, lib, ...}:

let
  # [ ProgramConfig ]
  enabledPrograms = builtins.filter
    (p: p.enabled)
    (builtins.attrValues config.sane.programs);

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
    (l: r: assert l.priority != r.priority; l.priority < r.priority)
    associations;
  sortMimes = mimes: builtins.mapAttrs (_k: sortOneMimeType) mimes;
  removePriorities = mimes: builtins.mapAttrs
    (_k: associations: builtins.map (a: a.desktop) associations)
    mimes;
in
{
  # the xdg mime type for a file can be found with:
  # - `xdg-mime query filetype path/to/thing.ext`
  # the default handler for a mime type can be found with:
  # - `xdg-mime query default <mimetype>`  (e.g. x-scheme-handler/http)
  #
  # we can have single associations or a list of associations.
  # there's also options to *remove* [non-default] associations from specific apps
  xdg.mime.enable = true;
  xdg.mime.defaultApplications = removePriorities (sortMimes (mergeMimes enabledWeightedMimes));


}
