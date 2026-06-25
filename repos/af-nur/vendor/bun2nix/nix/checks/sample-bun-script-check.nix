{
  perSystem =
    {
      pkgs,
      config,
      ...
    }:
    {
      checks.writeBunScriptBin =

        let
          inherit (config) writeBunScriptBin;

          script = writeBunScriptBin {
            name = "hello-world-bun-script";
            text =
              # JS
              ''
                import { $ } from "bun";

                await $`echo "Hello World!"`;
              '';
          };
        in
        pkgs.stdenv.mkDerivation {
          name = "sample-bun-script-check";

          dontBuild = true;

          src = ./.;

          doCheck = true;

          checkPhase = ''
            output=$(${script}/bin/hello-world-bun-script)

            if ! [[ "$output" == "Hello World!" ]]; then
              echo "Sample bun script did not produce expected output"
              exit 1
            fi
          '';

          installPhase = ''
            mkdir "$out"
          '';
        };
    };
}
