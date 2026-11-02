# Claude Code statusline plugin, run straight from its TypeScript source; $out doubles as the plugin root Claude Code loads.
{
  lib,
  stdenvNoCC,
  makeWrapper,
  nodejs_24,
  source,
}: let
  inherit (source) version;
in
  stdenvNoCC.mkDerivation {
    pname = "claude-hud";
    inherit version;
    inherit (source) src;

    nativeBuildInputs = [makeWrapper];

    # Upstream opens the config with O_NOFOLLOW, rejecting the symlink that is the only shape home-manager can deliver.
    # The regular-file check on the opened descriptor, the bounded read and the JSON shape check stay.
    postPatch = ''
      substituteInPlace src/config.ts collector.mjs \
        --replace-fail 'fs.constants.O_RDONLY | (fs.constants.O_NOFOLLOW ?? 0)' 'fs.constants.O_RDONLY'
    '';

    dontBuild = true;

    installPhase = ''
      runHook preInstall

      # Claude Code loads the plugin from $out itself, so the manifest, the skill and the code it runs stay at the root.
      mkdir -p $out
      cp -r .claude-plugin dist scripts skills src collector.mjs fence.mjs hud.mjs install.mjs $out/

      # node reads the module type from package.json, and /hud doctor the plugin version.
      install -Dm644 package.json $out/package.json

      makeWrapper ${lib.getExe nodejs_24} $out/bin/claude-hud \
        --add-flags $out/hud.mjs

      install -Dm644 LICENSE README.md -t $out/share/doc/claude-hud

      runHook postInstall
    '';

    doInstallCheck = true;
    installCheckPhase = ''
      runHook preInstallCheck

      grep -qF '"version": "${version}"' $out/.claude-plugin/plugin.json
      test -f $out/skills/hud/SKILL.md

      # The statusline renders one frame per stdin payload; this is upstream's own smoke input.
      payload='{"model":{"display_name":"Opus"},"context_window":{"current_usage":{"input_tokens":45000},"context_window_size":200000},"transcript_path":"/nonexistent/transcript.jsonl"}'
      echo "$payload" | $out/bin/claude-hud | grep -qF Opus

      # A symlink is the only shape home-manager can deliver, so prove the config still lands.
      hudHome=$(mktemp -d)
      mkdir -p "$hudHome/.claude/plugins/claude-hud"
      echo '{"language":"zh-Hans"}' >"$hudHome/config.json"
      ln -s "$hudHome/config.json" "$hudHome/.claude/plugins/claude-hud/config.json"
      echo "$payload" | HOME="$hudHome" $out/bin/claude-hud | grep -qF '上下文'

      test -f $out/share/doc/claude-hud/LICENSE
      test -f $out/share/doc/claude-hud/README.md

      runHook postInstallCheck
    '';

    meta = {
      description = "Real-time statusline HUD for Claude Code";
      homepage = "https://github.com/jarrodwatts/claude-hud";
      changelog = "https://github.com/jarrodwatts/claude-hud/releases/tag/${source.rev}";
      license = lib.licenses.mit;
      mainProgram = "claude-hud";
      maintainers = [
        {
          name = "mzwing";
        }
      ];
      platforms = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
    };
  }
