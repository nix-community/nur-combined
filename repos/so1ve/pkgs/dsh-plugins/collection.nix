{
  callPackage,
  deepseek-harness,
  lib,
  writeText,
}:

let
  pluginLib = callPackage ../../lib/plugins.nix { };
  host = callPackage ./purge-host.nix { inherit deepseek-harness; };
  plugins = lib.filterAttrs (_: lib.isDerivation) (callPackage ./. { deepseek-harness = host; });
  names = lib.remove "github:kingcharleslzy-ai/dsh-purge" (builtins.attrNames plugins) ++ [
    "github:kingcharleslzy-ai/dsh-purge"
  ];

  profile = writeText "dsh-plugins-profile.json" (
    builtins.toJSON {
      name = "dsh-plugins-check";
      private = true;

      dependencies = lib.listToAttrs (
        map (name: {
          name = plugins.${name}.packageName;
          value = "file:${plugins.${name}}/lib/node_modules/${plugins.${name}.packageName}";
        }) names
      );

      dsh.profile.bundles = [
        "@deepseek-ai/dsh-base"
        "@deepseek-ai/dsh-web-app"
      ]
      ++ map (name: plugins.${name}.packageName) names;
    }
  );
in
pluginLib.mkPluginCollection {
  name = "dsh-plugins";
  inherit plugins;
  extraLinks = {
    deepseek-harness-purge = host;
  };
  extraCheck = ''
    export DSH_HOME="$TMPDIR/dsh-check"
    profile="$DSH_HOME/profiles/web"

    mkdir -p "$profile"
    ln -s ${profile} "$profile/package.json"

    ${lib.concatMapStringsSep "\n" (name: ''
      mkdir -p "$profile/node_modules/${builtins.dirOf plugins.${name}.packageName}"
      ln -s ${plugins.${name}}/lib/node_modules/${plugins.${name}.packageName} \
        "$profile/node_modules/${plugins.${name}.packageName}"
    '') names}

    ${host}/bin/dsh --profile web --dump-config > /dev/null
    ${host}/bin/dsh --profile web --help > /dev/null 2> "$TMPDIR/boot.log"

    # purge-host.nix already verifies patch anchors at build time; ignore
    # dsh-purge-community's advisory notice for unlisted DSH RC versions.
    grep -v '^\[dsh-purge-community\] DSH .* 未在已验证清单内' "$TMPDIR/boot.log" > "$TMPDIR/boot-errors.log" || true

    if test -s "$TMPDIR/boot-errors.log"; then
      cat "$TMPDIR/boot-errors.log" >&2
      exit 1
    fi
  '';
}
