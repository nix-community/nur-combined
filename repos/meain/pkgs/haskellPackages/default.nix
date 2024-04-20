{
  pkgs,
  sources,
  ...
}: let
  callHaskellPackage = pkg: {
    compiler ? "ghc902",
    tagged ? false,
    attrs ? {},
    cabal2nixAttrs ? {},
  }:
    (pkgs.haskell.packages.${compiler}.callPackage pkg cabal2nixAttrs).overrideAttrs (oldAttrs: (
      let
        source = sources.${pkgs.lib.removeSuffix ".nix" (pkgs.lib.removePrefix "_" (builtins.baseNameOf pkg))};
      in
        {
          inherit (source) pname src;
          version =
            if tagged
            then source.version
            else source.date;
        }
        // attrs
    ));
in {
  kmonad = callHaskellPackage ./_kmonad.nix {
    compiler = "ghc92";
    attrs = {
      nativeBuildInputs = with pkgs; [
        removeReferencesTo
        (writeShellScriptBin "git" ''
          echo ${sources.kmonad.version}
        '')
      ];
      dontCheck = true;
    };
  };
}
