{
  autoPatchelfHook,
  callPackage,
  coreutils,
  fontconfig,
  gtk3,
  lib,
  libepoxy,
  makeShellWrapper,
  mpv-unwrapped,
  plugins ? [ ],
  source ? callPackage ./source.nix { },
  stdenv,
  wayland,
  wrapGAppsHook3,
  writeShellApplication,
  xdg-utils,
  yesplaymusic-plugins ? { },
}:

let
  pname = "yesplaymusic";
  inherit (source) version src;

  meta = {
    description = "Desktop music player with a plugin system";
    homepage = "https://github.com/qier222/YesPlayMusic";
    changelog = "https://github.com/qier222/YesPlayMusic/releases/tag/v${version}";
    license = lib.licenses.gpl3Only;
    mainProgram = pname;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
  };

  syncPluginsScript = writeShellApplication {
    name = "yesplaymusic-sync-plugins";
    runtimeInputs = [ coreutils ];
    text = ''
      data_home="''${XDG_DATA_HOME:-$HOME/.local/share}"
      plugins_dir="$data_home/YesPlayMusic/plugins"
      state_file="$plugins_dir/.nix-managed"

      mkdir -p "$plugins_dir"

      if [[ -f "$state_file" ]]; then
        while IFS= read -r old_id; do
          [[ -n "$old_id" ]] || continue
          if [[ -L "$plugins_dir/$old_id" ]]; then
            rm -f "$plugins_dir/$old_id"
          fi
        done < "$state_file"
      fi

      if (( $# == 0 )); then
        rm -f "$state_file"
        exit 0
      fi

      tmp_file="$(mktemp "$plugins_dir/.nix-managed.XXXXXX")"
      trap 'rm -f "$tmp_file"' EXIT

      while (( $# >= 2 )); do
        id="$1"
        target="$2"
        shift 2

        dest="$plugins_dir/$id"
        if [[ -e "$dest" && ! -L "$dest" ]]; then
          printf 'yesplaymusic: skipping Nix plugin %s because %s already exists and is not a symlink\n' "$id" "$dest" >&2
          continue
        fi

        ln -sfn "$target" "$dest"
        printf '%s\n' "$id" >> "$tmp_file"
      done

      if [[ -s "$tmp_file" ]]; then
        mv -f "$tmp_file" "$state_file"
      else
        rm -f "$state_file"
      fi
    '';
  };

  unwrapped = stdenv.mkDerivation {
    pname = "${pname}-unwrapped";
    inherit version src meta;

    nativeBuildInputs = [
      autoPatchelfHook
    ];

    buildInputs = [
      fontconfig
      gtk3
      libepoxy
      stdenv.cc.cc.lib
      wayland
    ];

    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall

      mkdir -p $out/app/yesplaymusic
      cp -r yesplaymusic lib data $out/app/yesplaymusic
      chmod +x $out/app/yesplaymusic/yesplaymusic

      install -Dm444 yesplaymusic.desktop \
        $out/share/applications/yesplaymusic.desktop
      install -Dm444 yesplaymusic.png \
        $out/share/icons/hicolor/512x512/apps/yesplaymusic.png

      runHook postInstall
    '';
  };

  mkYesPlayMusic =
    {
      plugins ? [ ],
    }:
    let
      pluginIds = map (plugin: plugin.pluginId) plugins;
      hasUniquePluginIds = builtins.length pluginIds == builtins.length (lib.unique pluginIds);
      pluginRuntimeDeps = lib.concatMap (plugin: plugin.runtimeDeps or [ ]) plugins;
      syncArgs = lib.concatMapStringsSep " " (
        plugin: "${lib.escapeShellArg plugin.pluginId} ${lib.escapeShellArg "${plugin}"}"
      ) plugins;
      syncCommand = "${lib.getExe syncPluginsScript}${
        lib.optionalString (plugins != [ ]) " ${syncArgs}"
      }";
    in
    assert lib.assertMsg hasUniquePluginIds
      "yesplaymusic: duplicate plugin IDs: ${lib.concatStringsSep ", " pluginIds}";
    stdenv.mkDerivation {
      inherit pname version meta;

      dontUnpack = true;
      dontConfigure = true;
      dontBuild = true;
      dontWrapGApps = true;

      nativeBuildInputs = [
        makeShellWrapper
        wrapGAppsHook3
      ];

      buildInputs = [
        gtk3
      ];

      installPhase = ''
        runHook preInstall

        mkdir -p $out/bin $out/share
        ln -s ${unwrapped}/share/applications $out/share/applications
        ln -s ${unwrapped}/share/icons $out/share/icons

        runHook postInstall
      '';

      preFixup = ''
        makeShellWrapper ${unwrapped}/app/yesplaymusic/yesplaymusic $out/bin/${pname} \
          "''${gappsWrapperArgs[@]}" \
          --prefix LD_LIBRARY_PATH : "${unwrapped}/app/yesplaymusic/lib:${
            lib.makeLibraryPath [ mpv-unwrapped ]
          }" \
          ${
            lib.optionalString (pluginRuntimeDeps != [ ]) ''
              --prefix PATH : "${lib.makeBinPath pluginRuntimeDeps}" \
            ''
          } \
          --suffix PATH : "${lib.makeBinPath [ xdg-utils ]}" \
          --run ${lib.escapeShellArg syncCommand}
      '';

      doInstallCheck = true;
      installCheckPhase = ''
        runHook preInstallCheck

        test -x $out/bin/${pname}
        test -f $out/share/applications/yesplaymusic.desktop
        test -f $out/share/icons/hicolor/512x512/apps/yesplaymusic.png

        # Verify Nix plugin sync creates managed symlinks, preserves manual plugins,
        # and cleans up removed Nix-managed links.
        export XDG_DATA_HOME="$TMPDIR/xdg"
        mkdir -p "$XDG_DATA_HOME/YesPlayMusic/plugins/manual-plugin"
        ln -s /nonexistent "$XDG_DATA_HOME/YesPlayMusic/plugins/stale-plugin"
        printf 'stale-plugin\n' > "$XDG_DATA_HOME/YesPlayMusic/plugins/.nix-managed"

        ${syncCommand}

        test -d "$XDG_DATA_HOME/YesPlayMusic/plugins/manual-plugin"
        test ! -e "$XDG_DATA_HOME/YesPlayMusic/plugins/stale-plugin"
        test ! -L "$XDG_DATA_HOME/YesPlayMusic/plugins/stale-plugin"

        ${lib.concatMapStringsSep "\n" (plugin: ''
          test -L "$XDG_DATA_HOME/YesPlayMusic/plugins/${plugin.pluginId}"
          test "$(readlink "$XDG_DATA_HOME/YesPlayMusic/plugins/${plugin.pluginId}")" = "${plugin}"
        '') plugins}

        ${lib.optionalString (plugins == [ ]) ''
          test ! -e "$XDG_DATA_HOME/YesPlayMusic/plugins/.nix-managed"
        ''}

        runHook postInstallCheck
      '';

      passthru = {
        inherit plugins unwrapped;
        withPlugins = selector: mkYesPlayMusic { plugins = selector yesplaymusic-plugins; };
      };
    };
in
mkYesPlayMusic { inherit plugins; }
