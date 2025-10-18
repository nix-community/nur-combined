{ self, ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      apps.check-nur-eval =
        let
          script = pkgs.writeShellApplication {
            name = "check-nur-eval";
            runtimeInputs = with pkgs; [
              nix
              jq
            ];
            text = ''
              cd ${self}
              nix-env -f . -qa \* --meta \
                --allowed-uris https://static.rust-lang.org \
                --option restrict-eval true \
                --option allow-import-from-derivation true \
                --drv-path --show-trace \
                -I nixpkgs=${pkgs.path} \
                -I ./ \
                --json | jq -r 'values | .[].name'
            '';
          };
        in
        {
          type = "app";
          program = "${pkgs.lib.getExe script}";
        };
    };
}
