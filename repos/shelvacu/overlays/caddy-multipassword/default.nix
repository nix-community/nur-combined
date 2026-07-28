finalPkgs: prev: {
  caddy = prev.caddy.overrideAttrs (
    finalAttrs: old: {
      patches = (old.patches or [ ]) ++ [ ./multipassword.patch ];
      prePatch = (old.prePatch or "") + ''
        isWithPlugins="false"
        if [[ -e vendor ]]; then
          isWithPlugins="true"
          pushd vendor/github.com/caddyserver/caddy/v2
        fi
      '';
      postPatch = (old.postPatch or "") + ''
        if [[ $isWithPlugins == true ]]; then
          popd
        fi
      '';
      passthru = old.passthru // {
        # withPlugins = throw "pkgs.caddy.withPlugins doesnt work with patches";
        withPlugins = finalPkgs.callPackage /${finalPkgs.path}/pkgs/by-name/ca/caddy/plugins.nix {
          caddy = finalAttrs.finalPackage;
        };
      };
    }
  );
}
