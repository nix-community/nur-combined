# Heavily modified version of @lucasew's `wrapWine` package.
# https://github.com/lucasew/nixcfg/blob/047c4913e9dceedd4957fb097bbf4803e5278563/nix/pkgs/wrapWine.nix

{ pkgs }:
let
  inherit (builtins) length concatStringsSep;
  inherit (pkgs) lib cabextract winetricks writeTextFile runtimeShell;
  inherit (lib) makeBinPath optionalString;
in
{ name
, executable
, workdir ? null

, is64bits ? true

, tricks ? [ ]
, silent ? true

, preScript ? ""
, postScript ? ""
, setupScript ? ""

, wine ? if is64bits then pkgs.wineWowPackages.stagingFull else pkgs.wine-staging
, wineFlags ? ""

# Useful for native linux apps that require wine environment (e.g. reaper with yabridge)
, isWinBin ? true
, meta ? {}
}:
let
  wineBin = "${wine}/bin/wine${optionalString is64bits "64"}";

  requiredPackages = [ wine cabextract ];

  tricksHook = optionalString ((length tricks) > 0) /* bash */ ''
    pushd $(mktemp -d)
      ${winetricks}/bin/winetricks ${optionalString silent "-q"} ${concatStringsSep " " tricks}
    popd
  '';
in writeTextFile {
  inherit name meta;

  text = /* bash */ ''
    #! ${runtimeShell}

    export WINEARCH=win${if is64bits then "64" else "32"}
    export PATH=${makeBinPath requiredPackages}:$PATH

    export WINE_NIX="$HOME/.wine-nix"
    export WINEPREFIX="$WINE_NIX/${name}"
    mkdir -p "$WINE_NIX"

    if [ ! -d "$WINEPREFIX" ]; then
      wineboot --init
      wineserver -w

      ${tricksHook}
      wineserver -w

      ${setupScript}
    fi

    ${optionalString (workdir != null) "cd \"${workdir}\""}

    # $REPL is defined => start a shell in the context
    if [ ! "$REPL" == "" ]; then
      bash; exit 0
    fi

    ${preScript}

    ${optionalString isWinBin "${wineBin} ${wineFlags}"} "${executable}" "$@"

    wineserver -w

    ${postScript}
  '';

  executable = true;
  destination = "/bin/${name}";
}
