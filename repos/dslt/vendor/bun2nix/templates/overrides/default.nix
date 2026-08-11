{
  bun2nix,
  runCommandLocal,
  ...
}:
bun2nix.mkDerivation {
  packageJson = ./package.json;

  src = ./.;

  bunDeps = bun2nix.fetchBunDeps {
    bunNix = ./bun.nix;
    overrides = {
      "typescript@5.9.3" =
        pkg:
        runCommandLocal "override-example" { } ''
          mkdir $out
          cp -r ${pkg}/. $out

          echo "hello world" > $out/my-override.txt
        '';
    };
  };

  postBunNodeModulesInstallPhase = ''
    if [ ! -f "node_modules/typescript/my-override.txt" ]; then
      echo "Text file created with override does not exist."
      exit 1
    fi
  '';
}
