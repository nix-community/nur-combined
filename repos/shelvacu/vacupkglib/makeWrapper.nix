{ pkgs, lib, ... }:
let
  inherit (lib)
    optionals
    optional
    mapAttrsToList
    concatMap
    escapeShellArg
    escapeShellArgs
    ;
in
{
  makeWrapper =
    {
      original,
      new,
      argv0 ? null,
      inherit_argv0 ? false,
      resolve_argv0 ? false,
      set ? { },
      set_default ? { },
      unset ? [ ],
      chdir ? null,
      run ? [ ],
      prepend_flags ? [ ],
      add_flags ? [ ],
      append_flags ? [ ],
      runtimeHook ? null,
      ...
    }@args:
    let
      drvAttrs = builtins.removeAttrs args [
        "original"
        "new"
        "argv0"
        "inherit_argv0"
        "resolve_argv0"
        "set"
        "set_default"
        "unset"
        "chdir"
        "run"
        "prepend_flags"
        "add_flags"
        "append_flags"
        "runtimeHook"
      ];
      prependFlags = prepend_flags ++ add_flags;
      originalBin = if lib.isDerivation original then lib.getExe original else original;
      makeWrapperFlags =
        (optionals (argv0 != null) [
          "--argv0"
          argv0
        ])
        ++ (optional inherit_argv0 "--inherit-argv0")
        ++ (optional resolve_argv0 "--resolve-argv0")
        ++ (mapAttrsToList (k: v: [
          "--set"
          k
          v
        ]) set)
        ++ (mapAttrsToList (k: v: [
          "--set-default"
          k
          v
        ]) set_default)
        ++ (concatMap (k: [
          "--unset"
          k
        ]) unset)
        ++ (optionals (chdir != null) [
          "--chdir"
          chdir
        ])
        ++ (concatMap (k: [
          "--run"
          k
        ]) run)
        ++ (optionals (prependFlags != [ ]) [
          "--add-flags"
          (escapeShellArgs prependFlags)
        ])
        ++ (optionals (append_flags != [ ]) [
          "--append-flags"
          (escapeShellArgs append_flags)
        ]);
      result = pkgs.stdenvNoCC.mkDerivation (
        drvAttrs
        // {
          name = new;

          nativeBuildInputs = [ pkgs.makeWrapper ] ++ (drvAttrs.nativeBuildInputs or [ ]);

          phases = [ "installPhase" ] ++ (drvAttrs.phases or [ ]);

          installPhase = ''
            runHook preInstall

            mkdir -p "$out"/bin
            makeWrapper ${escapeShellArg originalBin} "$out"/bin/${escapeShellArg new} ${escapeShellArgs makeWrapperFlags}

            runHook postInstall
          '';

          inherit runtimeHook;

          meta = {
            mainProgram = new;
          }
          // (drvAttrs.meta or { });
        }
      );
    in
    lib.pipe result [
      (lib.warnIf (drvAttrs ? name) "attempted to pass name to vacupkglib.makeWrapper; use new instead")
      (lib.warnIf (
        drvAttrs ? installPhase
      ) "attempted to pass installPhase to vacupkglib.makeWrapper; use preInstall or postInstall instead")
    ];
}
