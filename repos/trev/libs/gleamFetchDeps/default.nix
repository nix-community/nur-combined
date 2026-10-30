{
  lib,
  stdenvNoCC,
  gleam,
  toml-sort,
  cacert,
  gitMinimal,
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
        # without a version, the output path doesn't change with it
        ${if args ? version then "pname" else "name"} = "${pname}-gleam-deps";

        nativeBuildInputs = [
          gleam
          toml-sort
          cacert
          gitMinimal
        ];

        installPhase = ''
          runHook preInstall

          export HOME=$(mktemp -d)
          mkdir -p $out

          if [ -n "''${gleamRoot-}" ]; then
            cd "$gleamRoot"
          fi

          gleam deps download

          toml-sort --in-place --all build/packages/packages.toml

          # git checkouts aren't reproducible, gleam only checks the commits in
          # packages.toml
          rm -rf build/git build/packages/*/.git

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
