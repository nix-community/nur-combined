{
  callPackage,
  jq,
  lib,
  stdenvNoCC,
}:

let
  pluginLib = callPackage ../../lib/plugins.nix { };
  catalog = builtins.fromJSON (builtins.readFile ./catalog.json);
in
pluginLib.mkPluginSet {
  inherit catalog;
  manifestPath = ./manifest.json;

  buildPlugin =
    {
      name,
      plugin,
      source,
    }:
    stdenvNoCC.mkDerivation {
      pname = "yesplaymusic-plugin-${name}";
      inherit (source) version;

      src = pluginLib.fetchGitHubArchive source;

      nativeBuildInputs = [ jq ];

      dontConfigure = true;
      dontBuild = true;

      installPhase = ''
        runHook preInstall

        mkdir -p "$out"
        cp -r . "$out/"
        rm -rf "$out/.git" "$out/.github" "$out/.gitignore" "$out/test" "$out/tests" "$out"/README*

        ${
          if name == "qqmusic" then
            ''
              rm -rf "$out/helper" "$out/build-helper.sh" "$out/package.py" \
                "$out"/bin/darwin-* "$out"/bin/windows-*
              chmod +x "$out"/bin/linux-*/qqmusic-channel

              # Nix store paths are read-only and /bin/chmod does not exist on NixOS;
              # executable bits are already set above.
              substituteInPlace "$out/login.js" \
                --replace-fail \
                  ${lib.escapeShellArg "const process = host.spawn('/bin/chmod', ['u+x', `\${host.dir}/\${helperPath()}`]);"} \
                  "return; // Executable bits are already set in the Nix store."

              jq '
                del(.repository)
                | .permissions.process |= map(select(startswith("bin/linux-")))
              ' plugin.json > "$out/plugin.json"
            ''
          else
            ''
              # Strip repository so YesPlayMusic will not prompt or auto-update Nix-managed plugins.
              jq 'del(.repository)' plugin.json > "$out/plugin.json"
            ''
        }

        runHook postInstall
      '';

      doInstallCheck = true;
      installCheckPhase = ''
        runHook preInstallCheck

        jq -e --arg id ${lib.escapeShellArg source.id} '
          .id == $id
          and (.name | type == "string" and length > 0)
          and (has("repository") | not)
        ' "$out/plugin.json" > /dev/null

        entry="$(jq -r '.main // "index.js"' "$out/plugin.json")"
        test -f "$out/$entry"

        icon="$(jq -r '.icon // empty' "$out/plugin.json")"
        if [[ -n "$icon" ]]; then
          test -f "$out/$icon"
        fi

        ${lib.optionalString (name == "qqmusic") ''
          jq -e '
            .permissions.process
            | (index("/bin/chmod") | not)
            and all(startswith("bin/linux-"))
            and length == 2
          ' "$out/plugin.json" > /dev/null
          test -x "$out/bin/linux-amd64/qqmusic-channel"
          test -x "$out/bin/linux-arm64/qqmusic-channel"
          ! grep -Fq '/bin/chmod' "$out/login.js"
        ''}

        # QuickJS module loading rejects files whose realpath escapes the plugin directory.
        real_out="$(realpath "$out")"
        while IFS= read -r -d "" link; do
          target="$(realpath "$link")"
          case "$target" in
            "$real_out"/*) ;;
            *)
              echo "Plugin symlink escapes plugin directory: $link -> $target" >&2
              exit 1
              ;;
          esac
        done < <(find "$out" -type l -print0)

        runHook postInstallCheck
      '';

      passthru = {
        pluginId = source.id;
        runtimeDeps = [ ];
      };

      meta = {
        inherit (plugin) description;
        homepage = "https://github.com/${plugin.repository}";
        license = lib.licenses.${plugin.license};
        platforms = if name == "qqmusic" then lib.platforms.linux else lib.platforms.all;
      }
      // lib.optionalAttrs (name == "qqmusic") {
        sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
      };
    };
}
