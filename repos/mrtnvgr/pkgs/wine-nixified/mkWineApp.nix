{ mkWineEnv, writeShellApplication, lib }:

{ name

, executable
, workdir ? null

, preScript ? ""
, postScript ? ""

, isWindowsExe ? true
, wineFlags ? ""

, meta ? { }

, allowSubstitutes ? false

, ...
} @ envArgs:

let
  inherit (lib) optionalString;

  env = mkWineEnv (envArgs // {
    inherit name allowSubstitutes;
  });
in
(writeShellApplication {
  inherit name meta;

  text = /* bash */ ''
    # shellcheck disable=SC1091
    source "${env}/bin/${name}"

    # $REPL is defined => start a shell in the env
    if [ ! "$REPL" == "" ]; then
      bash; exit 0
    fi

    ${optionalString (workdir != null) "cd \"${workdir}\""}

    ${preScript}

    ${optionalString isWindowsExe "wine ${wineFlags}"} "${executable}" "$@"

    wineserver -w

    ${postScript}
  '';
}).overrideAttrs {
  # TODO: https://github.com/NixOS/nixpkgs/issues/344414
  inherit allowSubstitutes;
}
