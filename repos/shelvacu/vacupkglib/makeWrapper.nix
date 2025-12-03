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
    }:
    let
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
    in
    pkgs.stdenvNoCC.mkDerivation {
      name = new;

      nativeBuildInputs = [ pkgs.makeWrapper ];

      phases = [ "installPhase" ];

      installPhase = ''
        runHook preInstall

        mkdir -p "$out"/bin
        makeWrapper ${escapeShellArg originalBin} "$out"/bin/${escapeShellArg new} ${escapeShellArgs makeWrapperFlags}

        runHook postInstall
      '';

      inherit runtimeHook;

      meta.mainProgram = new;
    };
}
