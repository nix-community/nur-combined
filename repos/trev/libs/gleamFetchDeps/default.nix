{
  lib,
  stdenvNoCC,
  gleam,
  toml-sort,
}:

let
  # avoid deno https://github.com/NixOS/nixpkgs/issues/511900
  gleam' = gleam.overrideAttrs {
    nativeCheckInputs = [ ];
    doCheck = false;
  };
in

lib.makeOverridable (
  {
    hash ? "",
    pname,
    gleam ? gleam',
    ...
  }@args:
  let
    args' = removeAttrs args [
      "hash"
      "pname"
    ];
    hash' =
      if hash != "" then
        { outputHash = hash; }
      else
        {
          outputHash = "";
          outputHashAlgo = "sha256";
        };
  in
  stdenvNoCC.mkDerivation (
    finalAttrs:
    (
      args'
      // {
        pname = "${pname}-gleam-deps";

        nativeBuildInputs = [
          gleam
          toml-sort
        ];

        installPhase = ''
          runHook preInstall

          export HOME=$(mktemp -d)
          mkdir -p $out

          gleam deps download

          toml-sort --in-place --all build/packages/packages.toml 

          cp -Tr build $out

          runHook postInstall
        '';

        dontConfigure = true;
        dontBuild = true;
        dontFixup = true;
        outputHashMode = "recursive";
      }
      // hash'
    )
  )
)
