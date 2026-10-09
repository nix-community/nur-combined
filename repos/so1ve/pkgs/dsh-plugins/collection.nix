{
  callPackage,
  lib,
  runCommand,
  writeText,
}:

let
  host = callPackage ./purge-host.nix { };
  plugins = lib.filterAttrs (_: lib.isDerivation) (callPackage ./. { deepseek-harness = host; });
  names = lib.remove "github:YuJunZhiXue/dsh-purge" (builtins.attrNames plugins) ++ [
    "github:YuJunZhiXue/dsh-purge"
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
runCommand "dsh-plugins" { } ''
  export DSH_HOME="$TMPDIR/dsh-check"
  profile="$DSH_HOME/profiles/web"

  mkdir -p "$out" "$profile"
  ln -s ${host} "$out/deepseek-harness-purge"
  ln -s ${profile} "$profile/package.json"

  ${lib.concatMapStringsSep "\n" (name: ''
    mkdir -p "$profile/node_modules/${builtins.dirOf plugins.${name}.packageName}"
    ln -s ${plugins.${name}}/lib/node_modules/${plugins.${name}.packageName} \
      "$profile/node_modules/${plugins.${name}.packageName}"

    mkdir -p "$out/${builtins.dirOf name}"
    ln -s ${plugins.${name}} "$out/${name}"
  '') names}

  ${host}/bin/dsh --profile web --dump-config > /dev/null
  ${host}/bin/dsh --profile web --help > /dev/null 2> "$TMPDIR/boot.log"

  if test -s "$TMPDIR/boot.log"; then
    cat "$TMPDIR/boot.log" >&2
    exit 1
  fi
''
