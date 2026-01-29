{ pkgs, system }:
{
  compile = pkgs.lib.makeOverridable (
    {
      package,
      target ? pkgs.stdenv.buildPlatform.rust.rustcTarget,
      ...
    }:
    package.override
      {
        # fix for https://github.com/rust-cross/cargo-zigbuild/issues/162
        auditable = false;
      }
      .overrideAttrs
      (
        _: prev:
        let
          platform = pkgs.lib.systems.elaborate {
            config = target;
          };
          name = if builtins.hasAttr "pname" prev then prev.pname else prev.name;
          bin = if platform.isWindows then "${name}.exe" else name;
        in
        {
          nativeBuildInputs =
            with pkgs;
            [
              cargo-zigbuild
              jq
            ]
            ++ prev.nativeBuildInputs;

          doCheck = false;

          buildPhase = ''
            runHook preBuild

            export HOME=$(mktemp -d)

            build_dir="''${TMPDIR:-/tmp}/rust"
            mkdir -p "$build_dir"

            if [[ "${platform.system}" == "${system}" ]]; then
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
