{ pkgs }:
{
  compile = pkgs.lib.makeOverridable (
    {
      package,
      target ? pkgs.stdenv.buildPlatform.rust.rustcTarget,
      ...
    }:
    package.overrideAttrs (
      _: prev:
      let
        name = if (builtins.hasAttr "pname" prev) then prev.pname else prev.name;
        bin = if (builtins.match ".*windows.*" target != null) then "${name}.exe" else name;
      in
      {
        nativeBuildInputs =
          with pkgs;
          [
            cargo-zigbuild
            jq
          ]
          ++ builtins.filter (
            drv: builtins.match ".*auditable.*" (pkgs.lib.getName drv) == null
          ) prev.nativeBuildInputs;

        auditable = false;
        doCheck = false;

        buildPhase = ''
          runHook preBuild

          export HOME=$(mktemp -d)

          build_dir="''${TMPDIR:-/tmp}/rust"
          mkdir -p "$build_dir"

          if [[ "${target}" == "${pkgs.stdenv.hostPlatform.rust.rustcTarget}" ]]; then
            cargo build --release --target-dir "$build_dir"
          else
            cargo zigbuild --release --target-dir "$build_dir" --target "${target}"
          fi

          runHook postBuild
        '';

        installPhase = ''
          runHook preInstall

          package_name=$(cargo metadata --no-deps --format-version 1 | jq -r '.packages[0].name')
          release=$(find $build_dir -type f -executable -name "''${package_name}*")

          mkdir -p "$out/bin"
          mv "$release" "$out/bin/${bin}"

          runHook postInstall
        '';

        meta = prev.meta // {
          mainProgram = bin;
        };
      }
    )
  );
}
