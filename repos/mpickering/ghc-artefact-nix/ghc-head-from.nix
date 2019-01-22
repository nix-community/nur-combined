# Wraps ghc-head-from.sh to provide the jq dependency
{ writeScriptBin, lib, jq, runCommand, makeWrapper }:
let scr = writeScriptBin "ghc-head-from" ''${./ghc-head-from.sh} "$@"'';
in runCommand "ghc-head-from" { buildInputs = [makeWrapper scr]; }
					''makeWrapper ${scr}/bin/ghc-head-from $out/bin/ghc-head-from \
						--prefix PATH : ${lib.makeBinPath [jq]}''
