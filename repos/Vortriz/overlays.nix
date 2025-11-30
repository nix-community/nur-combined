let
    modifications = final: prev: {
        yaziPlugins =
            let
                inherit (prev.yaziPlugins) mkYaziPlugin;
                callPackage = prev.lib.callPackageWith final;
            in
            prev.yaziPlugins
            // (builtins.mapAttrs (name: _: callPackage ./pkgs/yaziPlugins/${name} { inherit mkYaziPlugin; }) (
                builtins.readDir ./pkgs/yaziPlugins
            ));
    };
in
{
    yaziPlugins = final: prev: (modifications final prev);
}
