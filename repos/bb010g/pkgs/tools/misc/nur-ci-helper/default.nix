{ lib, mkDerivation, runCommand
, base, foldl, pangraph, text, turtle
}:

mkDerivation {
  pname = "nur-ci-helper";
  version = "0.1.0.0";

  src = runCommand "nur-ci-helper-cabal" {
    src = ../../../../ci.hs;
  } ''
    mkdir -p "$out"
    cp "$src" "$out/Ci.hs"
    cp -t "$out" ${./nur-ci-helper.cabal}
  '';

  executableHaskellDepends = [ base foldl pangraph text turtle ];

  isLibrary = false;
  isExecutable = true;

  description = "A CI helper for NUR repos";
  license = with lib.licenses; isc;
  maintainers = with lib.maintainers; [ bb010g ];
}
