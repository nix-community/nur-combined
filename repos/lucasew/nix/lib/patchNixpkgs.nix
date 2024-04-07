{
  nixpkgs ? <nixpkgs>,
  patches ? [ ],
  system ? builtins.currentSystem,
  bootstrapPkgs ? import nixpkgs { inherit system; },
}:

let
  inherit (builtins) length;
  hasPatches = (length patches) > 0;

  patchedNixpkgs = bootstrapPkgs.stdenvNoCC.mkDerivation {
    name = "source";
    src = nixpkgs;
    phases = [
      "unpackPhase"
      "patchPhase"
      "installPhase"
    ];
    preferLocalBuild = true;
    installPhase = "cp -r . $out";
    inherit patches;
  };
in
if hasPatches then patchedNixpkgs else nixpkgs
