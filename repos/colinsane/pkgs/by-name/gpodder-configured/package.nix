# gpodder keeps all its feeds in a sqlite3 database.
# the binary provided here, `gpodder-ensure-feeds`, may be run to import
# my nix-synchronized feeds into gpodder, and remove any extras i've since deleted.
# repeat imports are deduplicated by url, even when offline.
# suggested usage: `gpodder-ensure-feeds ~/.config/gpodderFeeds.opml` as part of activation or some default .service

{
  gpodder,
  lib,
  listparser,
  makeShellWrapper,
  static-nix-shell,
}:

let
  remove-extra = static-nix-shell.mkPython3 {
    pname = "gpodder-ensure-feeds";
    srcRoot = ./.;
    pkgs = {
      # important for this to explicitly use `gpodder` here, because it may be overriden/different from the toplevel `gpodder`!
      inherit gpodder listparser;
    };
  };
in
  gpodder.overrideAttrs (upstream: {
    # use `makeShellWrapper` here so that we can get expansion of env vars like `$HOME`, at runtime
    nativeBuildInputs = (upstream.nativeBuildInputs or []) ++ [
      makeShellWrapper
    ];

    dontWrapGApps = true;
    postFixup = (upstream.postFixup or "") + ''
      # XXX(2025-03-21): splat the makeWrapperArgs here because upstream gpodder specifies
      # `--suffix PATH ...` all as _one_ argument, but makeShellWrapper requires it to be multiple :(
      # splat `extraMakeWrapperArgs` because nix passes that through as a single string instead of as a bash array.
      # be careful when changing this: we rely on `~` being expanded at the right time (i.e. by the python interpreter),
      # and never before that (e.g. the makePythonApplication c wrapper)
      makeWrapperArgs=(''${makeWrapperArgs[*]} "''${gappsWrapperArgs[@]}" ''${extraMakeWrapperArgs[@]})

      for f in $out/bin/*; do
        wrapProgramShell "$f" "''${makeWrapperArgs[@]}"
      done
      makeShellWrapper ${lib.getExe remove-extra} "$out/bin/${remove-extra.meta.mainProgram}" "''${makeWrapperArgs[@]}"
    '';

    passthru = (upstream.passthru or {}) // {
      inherit remove-extra;
    };
  })
